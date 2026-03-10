-- ============================================================================
-- Migration 018: Add commissary write policy for daily_sales_summary
-- ============================================================================
-- Problem:
--   Only franchisees (branches) have INSERT/UPDATE policies on
--   daily_sales_summary. The commissary can SELECT (view) but cannot write.
--   When the commissary syncs its own daily sales summaries, Supabase
--   returns 42501 (insufficient_privilege).
--
-- Fix:
--   Add INSERT and UPDATE policies for commissary users, scoped to their
--   own organization or franchisees in their network.
-- ============================================================================

-- Commissary can insert sales summaries for itself or its network
CREATE POLICY "Commissary can insert sales summaries"
    ON daily_sales_summary
    FOR INSERT TO authenticated
    WITH CHECK (
        is_commissary_user()
        AND (
            organization_id = get_current_user_organization_id()::TEXT
            OR EXISTS (
                SELECT 1 FROM organizations
                WHERE cloud_id::TEXT = organization_id
                AND parent_commissary_id = get_current_user_organization_id()
            )
        )
    );

-- Commissary can update sales summaries in their network
CREATE POLICY "Commissary can update sales summaries"
    ON daily_sales_summary
    FOR UPDATE TO authenticated
    USING (
        is_commissary_user()
        AND (
            organization_id = get_current_user_organization_id()::TEXT
            OR EXISTS (
                SELECT 1 FROM organizations
                WHERE cloud_id::TEXT = organization_id
                AND parent_commissary_id = get_current_user_organization_id()
            )
        )
    )
    WITH CHECK (
        is_commissary_user()
        AND (
            organization_id = get_current_user_organization_id()::TEXT
            OR EXISTS (
                SELECT 1 FROM organizations
                WHERE cloud_id::TEXT = organization_id
                AND parent_commissary_id = get_current_user_organization_id()
            )
        )
    );
