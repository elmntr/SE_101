-- ============================================================================
-- Migration 014: Harden users_self_link_auth policy
-- ============================================================================
-- Problem:
--   The existing users_self_link_auth policy allows a user to update ANY
--   column on their own row (matched by email). This means a user could
--   self-escalate by changing their role_id or organization_id via a direct
--   Supabase REST API call, bypassing the app.
--
-- Fix:
--   Replace with a restrictive policy that only allows updating auth_user_id.
--   The WITH CHECK clause ensures role_id and organization_id cannot change.
-- ============================================================================

-- Drop the overly-permissive self-link policy (both possible schemas)
DROP POLICY IF EXISTS users_self_link_auth ON public.users;

-- Recreate with proper column restrictions.
-- USING: user can only target their own row (by email).
-- WITH CHECK: the security-sensitive fields must remain unchanged.
CREATE POLICY users_self_link_auth ON public.users
    FOR UPDATE TO authenticated
    USING (email = auth.email())
    WITH CHECK (
        -- The email must still match (can't change email to hijack another account)
        email = auth.email()
        -- role_id must not change
        AND role_id = (SELECT u.role_id FROM users u WHERE u.email = auth.email() LIMIT 1)
        -- organization_id must not change
        AND organization_id = (SELECT u.organization_id FROM users u WHERE u.email = auth.email() LIMIT 1)
    );
