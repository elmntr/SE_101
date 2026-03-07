-- ============================================================================
-- Migration 015: Fix commissary update policy for stock_change_requests
-- ============================================================================
-- Problem:
--   The stock_changes_star_update policy only allows franchisees to update
--   their own change requests (NOT is_commissary_user()). This blocks the
--   commissary from approving or rejecting requests via the Supabase REST
--   API, resulting in 42501 (insufficient_privilege) errors.
--
-- Fix:
--   Drop and recreate the update policy so:
--   - Commissary can update (approve/reject) requests from franchisees
--     in their network.
--   - Franchisee can still update their own pending/draft requests.
-- ============================================================================

-- Drop the existing restrictive update policy
DROP POLICY IF EXISTS stock_changes_star_update ON stock_change_requests;

-- Recreate with commissary + franchisee scopes
CREATE POLICY stock_changes_star_update ON stock_change_requests
    FOR UPDATE TO authenticated
    USING (
        CASE
            WHEN is_commissary_user() THEN
                -- Commissary can update (approve/reject) requests from their network
                is_in_commissary_network(franchisee_id)
            ELSE
                -- Franchisee can update their own draft/pending requests
                franchisee_id = get_current_user_organization_id()
                AND status IN ('draft', 'pending')
        END
    )
    WITH CHECK (
        CASE
            WHEN is_commissary_user() THEN
                is_in_commissary_network(franchisee_id)
            ELSE
                franchisee_id = get_current_user_organization_id()
        END
    );
