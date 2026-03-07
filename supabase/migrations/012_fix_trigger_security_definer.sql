-- Migration 012: Fix create_branch_stock_for_new_item trigger function
-- 
-- Problem: The trigger function create_branch_stock_for_new_item() was missing
-- SECURITY DEFINER, so it ran as the invoker (commissary user). When the
-- commissary pushed a new item, the trigger tried to INSERT into branch_item_stock
-- with franchisee organization_ids, which the RLS INSERT policy rejected (42501)
-- because the policy only allows each org to insert its own rows.
--
-- Fix: Recreate the function with SECURITY DEFINER so it runs as the database
-- owner and bypasses RLS, which is the correct pattern for auto-population triggers.

CREATE OR REPLACE FUNCTION create_branch_stock_for_new_item()
RETURNS TRIGGER AS $$
BEGIN
    -- Only for master items (from commissary, i.e. no master_item_id)
    IF NEW.master_item_id IS NULL THEN
        -- Create stock records for all active franchisees under this commissary
        INSERT INTO branch_item_stock (organization_id, item_id, stock, created_at, last_updated)
        SELECT 
            o.cloud_id::TEXT,
            NEW.cloud_id,
            0,
            NOW(),
            NOW()
        FROM organizations o
        WHERE o.parent_commissary_id = NEW.organization_id
          AND o.is_active = TRUE
        ON CONFLICT (organization_id, item_id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
