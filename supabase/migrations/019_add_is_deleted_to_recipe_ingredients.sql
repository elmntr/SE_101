-- Migration 019: Add is_deleted soft-delete column to recipe_ingredients
--
-- Why: The Dart sync descriptor includes is_deleted as a field mapping, so the
-- app pushes `is_deleted: true/false` when syncing recipe ingredients. Without
-- this column the upsert fails with "column does not exist".
--
-- This is also required for the cascade-delete flow: when the commissary
-- soft-deletes a master item, all its recipe_ingredient rows are soft-deleted
-- locally and pushed to cloud with is_deleted=true so branches pull them down
-- and clean up on their next sync.
-- ============================================================================

ALTER TABLE recipe_ingredients
  ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN recipe_ingredients.is_deleted IS
  'Soft delete flag. Set to TRUE when the parent item is deleted or the '
  'recipe ingredient is individually removed. Synced to local SQLite via '
  'the is_deleted field mapping in the Dart sync descriptor.';

-- Index so the sync pull query (filtered by last_updated) stays fast even
-- when large numbers of rows are soft-deleted.
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_is_deleted
  ON recipe_ingredients(is_deleted)
  WHERE is_deleted = FALSE;
