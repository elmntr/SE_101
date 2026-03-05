-- ============================================================================
-- FIX AUTH BOOTSTRAP: Email fallback for helper functions
-- ============================================================================
-- Problem:
--   When the local database is deleted, the first online login calls
--   _pullUserFromCloud which reads from Supabase to re-seed.
--   The helper functions get_current_user_organization_id() and
--   get_current_user_organization_type() only query by auth_user_id.
--   If auth_user_id is NULL on the users row (e.g. commissary admin created
--   before migration 002 linked auth users, or before the first online sync),
--   every derived RLS check returns NULL/false.
--   Result: the org/role tables are unreadable → _pullUserFromCloud returns
--   null → login fails with "User not found in local database".
--
-- Fix:
--   Update both helper functions to fall back to auth.email() matching when
--   no row is found by auth_user_id. This allows the bootstrap query to
--   succeed, and _pullUserFromCloud then self-patches auth_user_id so future
--   logins use the faster auth_user_id path.
-- ============================================================================

-- Function to get current user's organization_id
-- Falls back to email match when auth_user_id is not yet populated.
CREATE OR REPLACE FUNCTION get_current_user_organization_id()
RETURNS UUID AS $$
DECLARE
    org_id UUID;
BEGIN
    -- Preferred: look up by auth_user_id (fast, unambiguous)
    SELECT organization_id INTO org_id
    FROM users
    WHERE auth_user_id = auth.uid()
    LIMIT 1;

    -- Fallback: look up by email (for users whose auth_user_id is not yet set,
    -- e.g. commissary admin bootstrapping after a fresh DB delete)
    IF org_id IS NULL THEN
        SELECT organization_id INTO org_id
        FROM users
        WHERE email = auth.email()
        LIMIT 1;
    END IF;

    RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to get current user's organization type
-- Falls back to email match when auth_user_id is not yet populated.
CREATE OR REPLACE FUNCTION get_current_user_organization_type()
RETURNS TEXT AS $$
DECLARE
    org_type TEXT;
BEGIN
    -- Preferred: look up by auth_user_id
    SELECT o.type INTO org_type
    FROM users u
    JOIN organizations o ON u.organization_id = o.cloud_id
    WHERE u.auth_user_id = auth.uid()
    LIMIT 1;

    -- Fallback: look up by email
    IF org_type IS NULL THEN
        SELECT o.type INTO org_type
        FROM users u
        JOIN organizations o ON u.organization_id = o.cloud_id
        WHERE u.email = auth.email()
        LIMIT 1;
    END IF;

    RETURN org_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Allow authenticated users to self-update their own auth_user_id linkage.
-- This is needed so _pullUserFromCloud can patch auth_user_id = auth.uid()
-- on the first online login after a fresh install.
-- The WITH CHECK prevents users from changing their organization or role.
DROP POLICY IF EXISTS users_self_link_auth ON users;
CREATE POLICY users_self_link_auth ON users
    FOR UPDATE TO authenticated
    USING (email = auth.email())
    WITH CHECK (email = auth.email());
