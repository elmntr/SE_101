-- ============================================================================
-- STAR TOPOLOGY ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Implements star topology where:
-- - Commissary (hub) can see ALL data from all franchisees
-- - Each Franchisee (spoke) can ONLY see their own data
-- ============================================================================

-- ============================================================================
-- STEP 1: Add auth_user_id column to users table for Supabase Auth linking
-- ============================================================================

-- Add Supabase Auth user ID column to link with auth.users
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_users_auth_user_id ON users(auth_user_id);

-- ============================================================================
-- STEP 2: Helper functions for RLS policies
-- ============================================================================

-- Function to get current user's organization_id
CREATE OR REPLACE FUNCTION get_current_user_organization_id()
RETURNS UUID AS $$
DECLARE
    org_id UUID;
BEGIN
    SELECT organization_id INTO org_id
    FROM users
    WHERE auth_user_id = auth.uid()
    LIMIT 1;
    RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to get current user's organization type
CREATE OR REPLACE FUNCTION get_current_user_organization_type()
RETURNS TEXT AS $$
DECLARE
    org_type TEXT;
BEGIN
    SELECT o.type INTO org_type
    FROM users u
    JOIN organizations o ON u.organization_id = o.cloud_id
    WHERE u.auth_user_id = auth.uid()
    LIMIT 1;
    RETURN org_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to check if current user is commissary
CREATE OR REPLACE FUNCTION is_commissary_user()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_current_user_organization_type() = 'commissary';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to get parent commissary ID for a franchisee
CREATE OR REPLACE FUNCTION get_parent_commissary_id(org_id UUID)
RETURNS UUID AS $$
DECLARE
    parent_id UUID;
BEGIN
    SELECT parent_commissary_id INTO parent_id
    FROM organizations
    WHERE cloud_id = org_id;
    RETURN parent_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to check if org belongs to current user's commissary network
CREATE OR REPLACE FUNCTION is_in_commissary_network(target_org_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_org_id UUID;
    current_org_type TEXT;
BEGIN
    current_org_id := get_current_user_organization_id();
    current_org_type := get_current_user_organization_type();
    
    -- If commissary, check if target is this commissary or one of its franchisees
    IF current_org_type = 'commissary' THEN
        RETURN (
            target_org_id = current_org_id 
            OR EXISTS (
                SELECT 1 FROM organizations 
                WHERE cloud_id = target_org_id 
                AND parent_commissary_id = current_org_id
            )
        );
    ELSE
        -- If franchisee, only allow own organization
        RETURN target_org_id = current_org_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================================================
-- STEP 3: Drop existing permissive policies
-- ============================================================================

DROP POLICY IF EXISTS organizations_select_policy ON organizations;
DROP POLICY IF EXISTS organizations_insert_policy ON organizations;
DROP POLICY IF EXISTS organizations_update_policy ON organizations;
DROP POLICY IF EXISTS organizations_delete_policy ON organizations;

DROP POLICY IF EXISTS roles_select_policy ON roles;
DROP POLICY IF EXISTS roles_insert_policy ON roles;
DROP POLICY IF EXISTS roles_update_policy ON roles;
DROP POLICY IF EXISTS roles_delete_policy ON roles;

DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

DROP POLICY IF EXISTS items_select_policy ON items;
DROP POLICY IF EXISTS items_insert_policy ON items;
DROP POLICY IF EXISTS items_update_policy ON items;
DROP POLICY IF EXISTS items_delete_policy ON items;

DROP POLICY IF EXISTS ingredients_select_policy ON ingredients;
DROP POLICY IF EXISTS ingredients_insert_policy ON ingredients;
DROP POLICY IF EXISTS ingredients_update_policy ON ingredients;
DROP POLICY IF EXISTS ingredients_delete_policy ON ingredients;

DROP POLICY IF EXISTS recipe_ingredients_select_policy ON recipe_ingredients;
DROP POLICY IF EXISTS recipe_ingredients_insert_policy ON recipe_ingredients;
DROP POLICY IF EXISTS recipe_ingredients_update_policy ON recipe_ingredients;
DROP POLICY IF EXISTS recipe_ingredients_delete_policy ON recipe_ingredients;

DROP POLICY IF EXISTS replenishment_select_policy ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_insert_policy ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_update_policy ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_delete_policy ON stock_replenishment_requests;

DROP POLICY IF EXISTS stock_changes_select_policy ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_insert_policy ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_update_policy ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_delete_policy ON stock_change_requests;

-- ============================================================================
-- STEP 4: Create Star Topology RLS Policies
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ORGANIZATIONS: Commissary sees all, franchisee sees self + parent commissary
-- ----------------------------------------------------------------------------
CREATE POLICY organizations_star_select ON organizations
    FOR SELECT USING (
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

CREATE POLICY organizations_star_insert ON organizations
    FOR INSERT WITH CHECK (
        -- Only commissary can create organizations
        is_commissary_user()
        AND (
            -- Can create franchisees under themselves
            parent_commissary_id = get_current_user_organization_id()
        )
    );

CREATE POLICY organizations_star_update ON organizations
    FOR UPDATE USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary can update self or child franchisees
                cloud_id = get_current_user_organization_id()
                OR parent_commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisee can only update self
                cloud_id = get_current_user_organization_id()
        END
    );

CREATE POLICY organizations_star_delete ON organizations
    FOR DELETE USING (
        -- Only commissary can delete (soft delete via is_active)
        is_commissary_user()
        AND parent_commissary_id = get_current_user_organization_id()
    );

-- ----------------------------------------------------------------------------
-- ROLES: All users can view roles, only commissary can manage
-- ----------------------------------------------------------------------------
CREATE POLICY roles_star_select ON roles
    FOR SELECT USING (true); -- Roles are shared across all organizations

CREATE POLICY roles_star_insert ON roles
    FOR INSERT WITH CHECK (is_commissary_user());

CREATE POLICY roles_star_update ON roles
    FOR UPDATE USING (is_commissary_user() AND NOT is_system_role);

CREATE POLICY roles_star_delete ON roles
    FOR DELETE USING (is_commissary_user() AND NOT is_system_role);

-- ----------------------------------------------------------------------------
-- USERS: Commissary sees all users in network, franchisee sees own users
-- ----------------------------------------------------------------------------
CREATE POLICY users_star_select ON users
    FOR SELECT USING (
        is_in_commissary_network(organization_id)
    );

CREATE POLICY users_star_insert ON users
    FOR INSERT WITH CHECK (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary can create users in their network
                is_in_commissary_network(organization_id)
            ELSE
                -- Franchisee can only create users in own organization
                organization_id = get_current_user_organization_id()
        END
    );

CREATE POLICY users_star_update ON users
    FOR UPDATE USING (
        CASE 
            WHEN is_commissary_user() THEN
                is_in_commissary_network(organization_id)
            ELSE
                organization_id = get_current_user_organization_id()
        END
    );

CREATE POLICY users_star_delete ON users
    FOR DELETE USING (
        CASE 
            WHEN is_commissary_user() THEN
                is_in_commissary_network(organization_id)
            ELSE
                organization_id = get_current_user_organization_id()
        END
    );

-- ----------------------------------------------------------------------------
-- ITEMS: Commissary sees all, franchisee sees own + master items
-- ----------------------------------------------------------------------------
CREATE POLICY items_star_select ON items
    FOR SELECT USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees all items in network
                is_in_commissary_network(organization_id)
            ELSE
                -- Franchisee sees own items + master items from commissary
                organization_id = get_current_user_organization_id()
                OR (
                    organization_id = get_parent_commissary_id(get_current_user_organization_id())
                    AND master_item_id IS NULL -- Master items only
                )
        END
    );

CREATE POLICY items_star_insert ON items
    FOR INSERT WITH CHECK (
        CASE 
            WHEN is_commissary_user() THEN
                organization_id = get_current_user_organization_id()
            ELSE
                organization_id = get_current_user_organization_id()
        END
    );

CREATE POLICY items_star_update ON items
    FOR UPDATE USING (
        organization_id = get_current_user_organization_id()
    );

CREATE POLICY items_star_delete ON items
    FOR DELETE USING (
        organization_id = get_current_user_organization_id()
    );

-- ----------------------------------------------------------------------------
-- INGREDIENTS: Commissary only (franchisees can view commissary's ingredients)
-- ----------------------------------------------------------------------------
CREATE POLICY ingredients_star_select ON ingredients
    FOR SELECT USING (
        CASE 
            WHEN is_commissary_user() THEN
                commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisees can view parent commissary's ingredients
                commissary_id = get_parent_commissary_id(get_current_user_organization_id())
        END
    );

CREATE POLICY ingredients_star_insert ON ingredients
    FOR INSERT WITH CHECK (
        is_commissary_user()
        AND commissary_id = get_current_user_organization_id()
    );

CREATE POLICY ingredients_star_update ON ingredients
    FOR UPDATE USING (
        is_commissary_user()
        AND commissary_id = get_current_user_organization_id()
    );

CREATE POLICY ingredients_star_delete ON ingredients
    FOR DELETE USING (
        is_commissary_user()
        AND commissary_id = get_current_user_organization_id()
    );

-- ----------------------------------------------------------------------------
-- RECIPE_INGREDIENTS: Commissary manages, franchisees can view
-- ----------------------------------------------------------------------------
CREATE POLICY recipe_ingredients_star_select ON recipe_ingredients
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM items 
            WHERE items.cloud_id = recipe_ingredients.item_id
            AND (
                items.organization_id = get_current_user_organization_id()
                OR (
                    NOT is_commissary_user()
                    AND items.organization_id = get_parent_commissary_id(get_current_user_organization_id())
                )
            )
        )
    );

CREATE POLICY recipe_ingredients_star_insert ON recipe_ingredients
    FOR INSERT WITH CHECK (
        is_commissary_user()
        AND EXISTS (
            SELECT 1 FROM items 
            WHERE items.cloud_id = recipe_ingredients.item_id
            AND items.organization_id = get_current_user_organization_id()
        )
    );

CREATE POLICY recipe_ingredients_star_update ON recipe_ingredients
    FOR UPDATE USING (
        is_commissary_user()
        AND EXISTS (
            SELECT 1 FROM items 
            WHERE items.cloud_id = recipe_ingredients.item_id
            AND items.organization_id = get_current_user_organization_id()
        )
    );

CREATE POLICY recipe_ingredients_star_delete ON recipe_ingredients
    FOR DELETE USING (
        is_commissary_user()
        AND EXISTS (
            SELECT 1 FROM items 
            WHERE items.cloud_id = recipe_ingredients.item_id
            AND items.organization_id = get_current_user_organization_id()
        )
    );

-- ----------------------------------------------------------------------------
-- STOCK_REPLENISHMENT_REQUESTS: Both parties see relevant requests
-- ----------------------------------------------------------------------------
CREATE POLICY replenishment_star_select ON stock_replenishment_requests
    FOR SELECT USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees all requests to them
                commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisee sees their own requests
                franchisee_id = get_current_user_organization_id()
        END
    );

CREATE POLICY replenishment_star_insert ON stock_replenishment_requests
    FOR INSERT WITH CHECK (
        -- Only franchisees can create requests
        NOT is_commissary_user()
        AND franchisee_id = get_current_user_organization_id()
        AND commissary_id = get_parent_commissary_id(get_current_user_organization_id())
    );

CREATE POLICY replenishment_star_update ON stock_replenishment_requests
    FOR UPDATE USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary can update (approve/reject) requests to them
                commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisee can update their pending requests
                franchisee_id = get_current_user_organization_id()
                AND status IN ('draft', 'pending')
        END
    );

CREATE POLICY replenishment_star_delete ON stock_replenishment_requests
    FOR DELETE USING (
        -- Only creator can delete draft requests
        NOT is_commissary_user()
        AND franchisee_id = get_current_user_organization_id()
        AND status = 'draft'
    );

-- ----------------------------------------------------------------------------
-- STOCK_CHANGE_REQUESTS: Within franchisee organization only
-- ----------------------------------------------------------------------------
CREATE POLICY stock_changes_star_select ON stock_change_requests
    FOR SELECT USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary can see all change requests in network
                is_in_commissary_network(franchisee_id)
            ELSE
                -- Franchisee sees their own requests
                franchisee_id = get_current_user_organization_id()
        END
    );

CREATE POLICY stock_changes_star_insert ON stock_change_requests
    FOR INSERT WITH CHECK (
        -- Only franchisee users can create change requests
        NOT is_commissary_user()
        AND franchisee_id = get_current_user_organization_id()
    );

CREATE POLICY stock_changes_star_update ON stock_change_requests
    FOR UPDATE USING (
        -- Only franchisee can update their own change requests
        NOT is_commissary_user()
        AND franchisee_id = get_current_user_organization_id()
    );

CREATE POLICY stock_changes_star_delete ON stock_change_requests
    FOR DELETE USING (
        NOT is_commissary_user()
        AND franchisee_id = get_current_user_organization_id()
        AND status = 'draft'
    );

-- ============================================================================
-- STEP 5: Service role bypass for sync operations
-- ============================================================================
-- The service_role key bypasses RLS automatically
-- For sync operations, use the service_role key in your server/backend

-- ============================================================================
-- STEP 6: Grant execute permissions on helper functions
-- ============================================================================
GRANT EXECUTE ON FUNCTION get_current_user_organization_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_organization_type() TO authenticated;
GRANT EXECUTE ON FUNCTION is_commissary_user() TO authenticated;
GRANT EXECUTE ON FUNCTION get_parent_commissary_id(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_in_commissary_network(UUID) TO authenticated;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON FUNCTION get_current_user_organization_id() IS 'Returns the organization_id of the currently authenticated user';
COMMENT ON FUNCTION get_current_user_organization_type() IS 'Returns "commissary" or "franchisee" based on current user';
COMMENT ON FUNCTION is_commissary_user() IS 'Returns true if current user belongs to a commissary organization';
COMMENT ON FUNCTION get_parent_commissary_id(UUID) IS 'Returns the parent commissary ID for a given organization';
COMMENT ON FUNCTION is_in_commissary_network(UUID) IS 'Checks if target org is in the same commissary network as current user';

-- ============================================================================
-- DONE: Star topology RLS is now active
-- ============================================================================
-- To test:
-- 1. Sign in as a commissary user -> should see all data
-- 2. Sign in as a franchisee user -> should only see own data + master items
-- ============================================================================
