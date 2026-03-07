-- ============================================================================
-- Migration 017: Remove unsafe UUID cast in branch_item_stock RLS
-- ============================================================================
-- Problem:
--   branch_item_stock_select casts organization_id::UUID but organization_id
--   is a TEXT column. If the value is not a valid UUID (e.g. empty string,
--   corrupted data), the cast throws and the entire SELECT fails for the
--   commissary user.
--
-- Fix:
--   Replace organization_id::UUID with get_current_user_organization_id()::TEXT
--   comparisons, which is always safe (UUID→TEXT never fails).
--   Also fix the insert policy to allow commissary to insert stock records
--   for franchisees in their network (needed by the auto-stock trigger).
-- ============================================================================

-- SELECT: Commissary sees network, franchisee sees own
DROP POLICY IF EXISTS branch_item_stock_select ON branch_item_stock;
CREATE POLICY branch_item_stock_select ON branch_item_stock
    FOR SELECT TO authenticated
    USING (
        CASE
            WHEN is_commissary_user() THEN
                -- Safe: cast UUID→TEXT instead of TEXT→UUID
                organization_id = get_current_user_organization_id()::TEXT
                OR EXISTS (
                    SELECT 1 FROM organizations
                    WHERE cloud_id::TEXT = organization_id
                    AND parent_commissary_id = get_current_user_organization_id()
                )
            ELSE
                organization_id = get_current_user_organization_id()::TEXT
        END
    );

-- INSERT: Each org inserts own, commissary can also insert for network
DROP POLICY IF EXISTS branch_item_stock_insert ON branch_item_stock;
CREATE POLICY branch_item_stock_insert ON branch_item_stock
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = get_current_user_organization_id()::TEXT
        OR (
            is_commissary_user()
            AND EXISTS (
                SELECT 1 FROM organizations
                WHERE cloud_id::TEXT = organization_id
                AND parent_commissary_id = get_current_user_organization_id()
            )
        )
    );

-- UPDATE: Each org updates own
DROP POLICY IF EXISTS branch_item_stock_update ON branch_item_stock;
CREATE POLICY branch_item_stock_update ON branch_item_stock
    FOR UPDATE TO authenticated
    USING (
        organization_id = get_current_user_organization_id()::TEXT
        OR (
            is_commissary_user()
            AND EXISTS (
                SELECT 1 FROM organizations
                WHERE cloud_id::TEXT = organization_id
                AND parent_commissary_id = get_current_user_organization_id()
            )
        )
    );

-- DELETE: Each org deletes own
DROP POLICY IF EXISTS branch_item_stock_delete ON branch_item_stock;
CREATE POLICY branch_item_stock_delete ON branch_item_stock
    FOR DELETE TO authenticated
    USING (
        organization_id = get_current_user_organization_id()::TEXT
    );
