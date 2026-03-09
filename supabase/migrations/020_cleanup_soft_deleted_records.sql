-- Migration 020: Cleanup function for soft-deleted records
-- ============================================================================
-- Purpose:
--   Hard-deletes rows that were soft-deleted (is_deleted = TRUE) and whose
--   last_updated timestamp is older than a configurable threshold (default: 30
--   days). This is the cloud-side counterpart to the local
--   _cleanupDeletedRecords() call in supabase_sync_service_v2.dart.
--
-- Why last_updated instead of deleted_at:
--   None of the tables have a dedicated deleted_at column. Soft-delete always
--   stamps last_updated = NOW() (via softDeleteItem / softDeleteByItemId /
--   deleteAllForItem), so last_updated is a reliable proxy for deletion time.
--
-- Why is_synced is NOT used for items / recipe_ingredients:
--   is_synced only exists on branch_item_stock in the cloud schema (migration
--   008). For the other two tables it is a local-SQLite-only column. Using
--   last_updated < cutoff is sufficient: rows that are 30+ days old in the
--   cloud have already been pulled by every connected client.
--
-- Deletion order (respects logical dependency):
--   1. recipe_ingredients  — references items via item_id (TEXT)
--   2. branch_item_stock   — references items via item_id (TEXT)
--   3. items               — master catalog row
--
-- Usage:
--   SELECT * FROM cleanup_soft_deleted_records();          -- default 30 days
--   SELECT * FROM cleanup_soft_deleted_records(60);        -- 60-day window
--
-- Schedule (pg_cron, recommended):
--   See commented block at the bottom of this file.
-- ============================================================================

-- ============================================================================
-- STEP 1: Create the cleanup function
-- ============================================================================

CREATE OR REPLACE FUNCTION cleanup_soft_deleted_records(
  older_than_days INTEGER DEFAULT 30
)
RETURNS TABLE (
  deleted_recipe_ingredients BIGINT,
  deleted_branch_item_stock  BIGINT,
  deleted_items              BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_cutoff     TIMESTAMPTZ := NOW() - (older_than_days || ' days')::INTERVAL;
  v_del_recipe BIGINT      := 0;
  v_del_stock  BIGINT      := 0;
  v_del_items  BIGINT      := 0;
BEGIN
  -- Validate input
  IF older_than_days < 1 THEN
    RAISE EXCEPTION 'older_than_days must be >= 1, got %', older_than_days;
  END IF;

  -- ------------------------------------------------------------------
  -- 1. recipe_ingredients
  --    Deleted first because they logically belong to the item and
  --    would become orphaned once the parent item row is removed.
  -- ------------------------------------------------------------------
  DELETE FROM recipe_ingredients
  WHERE is_deleted = TRUE
    AND last_updated < v_cutoff;

  GET DIAGNOSTICS v_del_recipe = ROW_COUNT;

  -- ------------------------------------------------------------------
  -- 2. branch_item_stock
  --    Deleted second. These stock rows are already flagged is_deleted
  --    by the cascade in softDeleteByItemId(). We additionally require
  --    is_synced = TRUE here because the column exists on this table,
  --    giving an extra guarantee that every branch received the signal
  --    before the cloud row is erased.
  -- ------------------------------------------------------------------
  DELETE FROM branch_item_stock
  WHERE is_deleted = TRUE
    AND is_synced  = TRUE
    AND last_updated < v_cutoff;

  GET DIAGNOSTICS v_del_stock = ROW_COUNT;

  -- ------------------------------------------------------------------
  -- 3. items
  --    Deleted last. At this point all dependent rows are gone.
  -- ------------------------------------------------------------------
  DELETE FROM items
  WHERE is_deleted = TRUE
    AND last_updated < v_cutoff;

  GET DIAGNOSTICS v_del_items = ROW_COUNT;

  -- Return a single summary row
  RETURN QUERY SELECT v_del_recipe, v_del_stock, v_del_items;
END;
$$;

COMMENT ON FUNCTION cleanup_soft_deleted_records(INTEGER) IS
  'Hard-deletes cloud rows soft-deleted (is_deleted = TRUE) more than '
  'older_than_days days ago (default 30). '
  'Order: recipe_ingredients → branch_item_stock (requires is_synced=TRUE) → items. '
  'SECURITY DEFINER — callable only by service_role or postgres.';

-- ============================================================================
-- STEP 2: Lock down permissions
--   PUBLIC (including anon / authenticated roles) must not be able to call
--   this function. Only service_role (Supabase server-side) and the postgres
--   superuser may invoke it.
-- ============================================================================

REVOKE EXECUTE ON FUNCTION cleanup_soft_deleted_records(INTEGER) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION cleanup_soft_deleted_records(INTEGER) TO service_role;

-- ============================================================================
-- STEP 3: Partial indexes to make the cleanup DELETE queries fast
--   These indexes help the planner find is_deleted=TRUE rows efficiently
--   without scanning the entire table each time.
-- ============================================================================

-- items — filter by (is_deleted, last_updated)
CREATE INDEX IF NOT EXISTS idx_items_deleted_cleanup
  ON items(last_updated)
  WHERE is_deleted = TRUE;

-- branch_item_stock — filter by (is_deleted, is_synced, last_updated)
CREATE INDEX IF NOT EXISTS idx_branch_item_stock_deleted_cleanup
  ON branch_item_stock(last_updated)
  WHERE is_deleted = TRUE AND is_synced = TRUE;

-- recipe_ingredients — filter by (is_deleted, last_updated)
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_deleted_cleanup
  ON recipe_ingredients(last_updated)
  WHERE is_deleted = TRUE;

-- ============================================================================
-- STEP 4 (OPTIONAL): Schedule with pg_cron
--   Enable the pg_cron extension in Supabase Dashboard under
--   Database → Extensions → pg_cron, then uncomment the block below.
--
--   The job runs every Sunday at 03:00 UTC (low-traffic window).
--   Adjust the cron expression to match your maintenance window.
-- ============================================================================

-- SELECT cron.schedule(
--   'cleanup-soft-deleted-records',   -- job name (must be unique)
--   '0 3 * * 0',                      -- every Sunday at 03:00 UTC
--   $$SELECT cleanup_soft_deleted_records()$$
-- );
