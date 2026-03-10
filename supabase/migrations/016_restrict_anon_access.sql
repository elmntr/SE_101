    -- ============================================================================
    -- Migration 016: Restrict anonymous access to roles
    -- ============================================================================
    -- Problem:
    --   roles_anon_select exposes the full roles table to unauthenticated
    --   requests. Anonymous users don't need role information.
    --
    --   organizations_anon_select is narrowed to active orgs only.
    --   Commissary orgs must remain visible so the HQ access gate can read
    --   hq_access_code_hash before the user authenticates.
    --
    -- Fix:
    --   1. Restrict organizations_anon_select to active orgs only (both
    --      franchisees for login dropdown AND commissary for HQ gate).
    --   2. Drop roles_anon_select entirely.
    -- ============================================================================

    -- 1. Fix organizations anonymous select — keep active orgs visible
    --    (commissary needed for HQ gate, franchisees needed for branch dropdown)
    DROP POLICY IF EXISTS organizations_anon_select ON organizations;
    CREATE POLICY organizations_anon_select ON organizations
        FOR SELECT TO anon
        USING (is_active = true);

    -- 2. Remove anonymous role access
    DROP POLICY IF EXISTS roles_anon_select ON roles;
