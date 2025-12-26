-- ============================================================================
-- FIX RLS POLICIES FOR BRANCH/FRANCHISEE OPERATIONS
-- ============================================================================
-- This migration fixes RLS policies to allow:
-- 1. Branch managers/admins to create employee accounts (users)
-- 2. Branch to manage their own items  
-- 3. Branch to view organizations/roles but NOT create them
-- 4. Commissary/superadmin to monitor all branch data
-- ============================================================================

-- ============================================================================
-- STEP 1: Fix USERS table RLS - Allow franchisees to create employees
-- ============================================================================

-- Drop existing user policies
DROP POLICY IF EXISTS users_star_select ON users;
DROP POLICY IF EXISTS users_star_insert ON users;
DROP POLICY IF EXISTS users_star_update ON users;
DROP POLICY IF EXISTS users_star_delete ON users;

-- Allow authenticated users to read users in their network + their own record
CREATE POLICY users_star_select ON users
    FOR SELECT TO authenticated
    USING (
        -- User can always read their own record (for login flow)
        auth_user_id = auth.uid()
        OR email = auth.email()
        -- Or if commissary, see all users in network
        OR (is_commissary_user() AND is_in_commissary_network(organization_id))
        -- Or if franchisee, see users in same organization
        OR (NOT is_commissary_user() AND organization_id = get_current_user_organization_id())
    );

-- Allow franchisees to create employees in their own organization
-- Allow commissary to create users anywhere in their network
CREATE POLICY users_star_insert ON users
    FOR INSERT TO authenticated
    WITH CHECK (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary can create users anywhere in their network
                is_in_commissary_network(organization_id)
            ELSE
                -- Franchisee can ONLY create users in their own organization
                organization_id = get_current_user_organization_id()
        END
    );

-- Allow users to update within their scope
CREATE POLICY users_star_update ON users
    FOR UPDATE TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN
                is_in_commissary_network(organization_id)
            ELSE
                -- Franchisee can update users in their organization (e.g., branch managers)
                organization_id = get_current_user_organization_id()
        END
    )
    WITH CHECK (
        CASE 
            WHEN is_commissary_user() THEN
                is_in_commissary_network(organization_id)
            ELSE
                organization_id = get_current_user_organization_id()
        END
    );

-- Allow deletion within scope (soft delete preferred)
CREATE POLICY users_star_delete ON users
    FOR DELETE TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN
                is_in_commissary_network(organization_id)
            ELSE
                organization_id = get_current_user_organization_id()
        END
    );

-- ============================================================================
-- STEP 2: Fix ORGANIZATIONS table RLS
-- Franchisees should NOT be able to INSERT organizations
-- They should only be able to READ their own org and parent commissary
-- ============================================================================

DROP POLICY IF EXISTS organizations_anon_select ON organizations;
DROP POLICY IF EXISTS organizations_star_select ON organizations;
DROP POLICY IF EXISTS organizations_star_insert ON organizations;
DROP POLICY IF EXISTS organizations_star_update ON organizations;
DROP POLICY IF EXISTS organizations_star_delete ON organizations;

-- Anonymous can read active franchisees for login screen branch dropdown
CREATE POLICY organizations_anon_select ON organizations
    FOR SELECT TO anon
    USING (is_active = true);

-- Authenticated users see based on their role
CREATE POLICY organizations_star_select ON organizations
    FOR SELECT TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees: self + all child franchisees
                cloud_id = get_current_user_organization_id()
                OR parent_commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisee sees: self + parent commissary
                cloud_id = get_current_user_organization_id()
                OR cloud_id = get_parent_commissary_id(get_current_user_organization_id())
        END
    );

-- ONLY Commissary can create organizations (franchisee branches)
CREATE POLICY organizations_star_insert ON organizations
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Only commissary can create organizations
        is_commissary_user()
        AND (
            -- Can create franchisees under themselves
            parent_commissary_id = get_current_user_organization_id()
            -- Or if it's their own organization (initial setup)
            OR cloud_id = get_current_user_organization_id()
        )
    );

-- Commissary can update their network, franchisee can update self only
CREATE POLICY organizations_star_update ON organizations
    FOR UPDATE TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary can update self or child franchisees
                cloud_id = get_current_user_organization_id()
                OR parent_commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisee can only update their own org details
                cloud_id = get_current_user_organization_id()
        END
    );

-- Only commissary can delete (soft delete via is_active)
CREATE POLICY organizations_star_delete ON organizations
    FOR DELETE TO authenticated
    USING (
        is_commissary_user()
        AND parent_commissary_id = get_current_user_organization_id()
    );

-- ============================================================================
-- STEP 3: Fix ROLES table RLS
-- Roles are global - everyone can read, only commissary can manage
-- ============================================================================

DROP POLICY IF EXISTS roles_star_select ON roles;
DROP POLICY IF EXISTS roles_star_insert ON roles;
DROP POLICY IF EXISTS roles_star_update ON roles;
DROP POLICY IF EXISTS roles_star_delete ON roles;

-- Everyone can read roles (needed for user creation and permission checks)
CREATE POLICY roles_star_select ON roles
    FOR SELECT TO authenticated
    USING (true);

-- Anonymous users can also read roles (for signup flow if needed)
CREATE POLICY roles_anon_select ON roles
    FOR SELECT TO anon
    USING (true);

-- Only commissary can create new roles
CREATE POLICY roles_star_insert ON roles
    FOR INSERT TO authenticated
    WITH CHECK (is_commissary_user());

-- Only commissary can update roles (except system roles)
CREATE POLICY roles_star_update ON roles
    FOR UPDATE TO authenticated
    USING (is_commissary_user() AND NOT is_system_role)
    WITH CHECK (is_commissary_user() AND NOT is_system_role);

-- Only commissary can delete roles (except system roles)
CREATE POLICY roles_star_delete ON roles
    FOR DELETE TO authenticated
    USING (is_commissary_user() AND NOT is_system_role);

-- ============================================================================
-- STEP 4: Fix ITEMS table RLS - Allow franchisees to manage their own items
-- ============================================================================

DROP POLICY IF EXISTS items_star_select ON items;
DROP POLICY IF EXISTS items_star_insert ON items;
DROP POLICY IF EXISTS items_star_update ON items;
DROP POLICY IF EXISTS items_star_delete ON items;

-- Commissary sees all items in network
-- Franchisee sees own items + master items from commissary
CREATE POLICY items_star_select ON items
    FOR SELECT TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees all items in their network
                is_in_commissary_network(organization_id)
            ELSE
                -- Franchisee sees their own items + master items from commissary
                organization_id = get_current_user_organization_id()
                OR (
                    organization_id = get_parent_commissary_id(get_current_user_organization_id())
                    AND master_item_id IS NULL -- Master items only
                )
        END
    );

-- Both commissary and franchisee can create items in their own organization
CREATE POLICY items_star_insert ON items
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Users can only create items in their own organization
        organization_id = get_current_user_organization_id()
    );

-- Users can only update items in their own organization
CREATE POLICY items_star_update ON items
    FOR UPDATE TO authenticated
    USING (organization_id = get_current_user_organization_id())
    WITH CHECK (organization_id = get_current_user_organization_id());

-- Users can only delete items in their own organization
CREATE POLICY items_star_delete ON items
    FOR DELETE TO authenticated
    USING (organization_id = get_current_user_organization_id());

-- ============================================================================
-- STEP 5: Add CATEGORIES table RLS (if table exists)
-- ============================================================================

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
        -- Enable RLS on categories
        EXECUTE 'ALTER TABLE categories ENABLE ROW LEVEL SECURITY';
        
        -- Drop existing policies
        DROP POLICY IF EXISTS categories_select ON categories;
        DROP POLICY IF EXISTS categories_insert ON categories;
        DROP POLICY IF EXISTS categories_update ON categories;
        DROP POLICY IF EXISTS categories_delete ON categories;
        
        -- Categories are shared - everyone can read
        EXECUTE 'CREATE POLICY categories_select ON categories FOR SELECT TO authenticated USING (true)';
        
        -- Only commissary can manage categories
        EXECUTE 'CREATE POLICY categories_insert ON categories FOR INSERT TO authenticated WITH CHECK (is_commissary_user())';
        EXECUTE 'CREATE POLICY categories_update ON categories FOR UPDATE TO authenticated USING (is_commissary_user())';
        EXECUTE 'CREATE POLICY categories_delete ON categories FOR DELETE TO authenticated USING (is_commissary_user())';
    END IF;
END $$;

-- ============================================================================
-- STEP 6: Ensure all functions have proper permissions
-- ============================================================================

GRANT EXECUTE ON FUNCTION get_current_user_organization_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_organization_type() TO authenticated;
GRANT EXECUTE ON FUNCTION is_commissary_user() TO authenticated;
GRANT EXECUTE ON FUNCTION get_parent_commissary_id(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_in_commissary_network(UUID) TO authenticated;

-- ============================================================================
-- SUMMARY OF PERMISSIONS:
-- ============================================================================
-- 
-- ORGANIZATIONS:
--   - SELECT: Commissary sees all in network; Franchisee sees self + parent
--   - INSERT: ONLY Commissary can create new organizations
--   - UPDATE: Commissary for network; Franchisee for self only
--   - DELETE: ONLY Commissary (for child franchisees)
--
-- ROLES:
--   - SELECT: Everyone (authenticated + anon)
--   - INSERT/UPDATE/DELETE: ONLY Commissary (except system roles)
--
-- USERS:
--   - SELECT: Own record + organization members + network for commissary
--   - INSERT: Commissary for network; Franchisee for own org (create employees!)
--   - UPDATE: Commissary for network; Franchisee for own org
--   - DELETE: Same as update scope
--
-- ITEMS:
--   - SELECT: Commissary sees network; Franchisee sees own + master items
--   - INSERT/UPDATE/DELETE: Only in own organization
--
-- ============================================================================
