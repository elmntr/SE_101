-- ============================================================================
-- MULTI-BRANCH INVENTORY RESTRUCTURING
-- ============================================================================
-- This migration restructures the database to support:
-- 1. Centralized Product Catalog (commissary_items as master)
-- 2. Decentralized Inventory (branch_item_stock per branch)
-- 3. Decentralized Sales (daily_sales_summary per branch)
-- ============================================================================

-- ============================================================================
-- STEP 1: Create branch_item_stock table
-- ============================================================================
-- This table stores per-branch inventory levels for items
-- The Items table becomes the "master catalog" with no stock
-- Each branch has their own stock record in this table

CREATE TABLE IF NOT EXISTS branch_item_stock (
    -- Primary key
    cloud_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    local_id INTEGER,
    
    -- Which branch owns this stock (TEXT to match organizations.cloud_id type)
    organization_id TEXT NOT NULL,
    
    -- Reference to master item from commissary (TEXT to match items.cloud_id type)
    item_id TEXT NOT NULL,
    
    -- Current stock quantity at this branch
    stock INTEGER NOT NULL DEFAULT 0,
    
    -- Total sold (cumulative or daily-reset depending on business needs)
    sold INTEGER NOT NULL DEFAULT 0,
    
    -- Total spoilage
    spoilage INTEGER NOT NULL DEFAULT 0,
    
    -- Branch-specific pricing (overrides master item price if set)
    price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    
    -- Minimum stock threshold for low stock alerts
    minimum_stock INTEGER,
    
    -- Last time this branch received a delivery
    last_received_at TIMESTAMPTZ,
    last_received_quantity INTEGER,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Sync tracking
    is_synced BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    -- Ensure one stock record per item per branch
    CONSTRAINT unique_branch_item_stock UNIQUE (organization_id, item_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_branch_item_stock_org ON branch_item_stock(organization_id);
CREATE INDEX IF NOT EXISTS idx_branch_item_stock_item ON branch_item_stock(item_id);
CREATE INDEX IF NOT EXISTS idx_branch_item_stock_last_updated ON branch_item_stock(last_updated);

-- ============================================================================
-- STEP 2: Fix Items table - Make it a master catalog
-- ============================================================================
-- For the star topology, commissary items are the master catalog
-- Franchisees don't duplicate items, they just have stock records

-- Ensure organization_id is UUID type (if not already fixed)
-- Note: Run the previous migration first if organization_id is still INTEGER

-- Add index for master items lookup
CREATE INDEX IF NOT EXISTS idx_items_master ON items(organization_id) WHERE master_item_id IS NULL;

-- ============================================================================
-- STEP 3: Skip UUID type conversion (existing schema uses TEXT for cloud_ids)
-- ============================================================================
-- NOTE: The existing tables use TEXT type for cloud_id columns.
-- We'll keep using TEXT to maintain compatibility.
-- No ALTER TABLE statements needed - the sync service handles UUID<->TEXT conversion.

-- ============================================================================
-- STEP 4: RLS Policies for branch_item_stock
-- ============================================================================

ALTER TABLE branch_item_stock ENABLE ROW LEVEL SECURITY;

-- SELECT: Commissary sees all, franchisee sees own
-- Note: Cast UUID to TEXT for comparison since organization_id is TEXT
CREATE POLICY branch_item_stock_select ON branch_item_stock
    FOR SELECT USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees all stock in their network
                is_in_commissary_network(organization_id::UUID)
            ELSE
                -- Franchisee sees only their own stock
                organization_id = get_current_user_organization_id()::TEXT
        END
    );

-- INSERT: Each org can only insert their own stock
CREATE POLICY branch_item_stock_insert ON branch_item_stock
    FOR INSERT WITH CHECK (
        organization_id = get_current_user_organization_id()::TEXT
    );

-- UPDATE: Each org can only update their own stock
CREATE POLICY branch_item_stock_update ON branch_item_stock
    FOR UPDATE USING (
        organization_id = get_current_user_organization_id()::TEXT
    );

-- DELETE: Each org can only delete their own stock
CREATE POLICY branch_item_stock_delete ON branch_item_stock
    FOR DELETE USING (
        organization_id = get_current_user_organization_id()::TEXT
    );

-- ============================================================================
-- STEP 5: Update existing RLS policies to use UUID comparison
-- ============================================================================

-- Drop and recreate items policy to ensure proper UUID filtering
DROP POLICY IF EXISTS items_star_select ON items;
CREATE POLICY items_star_select ON items
    FOR SELECT USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees all items in network
                is_in_commissary_network(organization_id)
            ELSE
                -- Franchisee sees their own items + master items from commissary
                organization_id = get_current_user_organization_id()
                OR (
                    organization_id = get_parent_commissary_id(get_current_user_organization_id())
                    AND master_item_id IS NULL  -- Master items only
                )
        END
    );

-- ============================================================================
-- STEP 6: Helper view for franchisee product catalog with stock
-- ============================================================================

CREATE OR REPLACE VIEW franchisee_products AS
SELECT 
    i.cloud_id as item_id,
    i.name as item_name,
    i.description,
    bis.cloud_id as stock_id,
    bis.organization_id as branch_id,
    bis.stock,
    bis.sold,
    bis.spoilage,
    COALESCE(bis.price, i.price) as price,
    COALESCE(bis.cost_price, i.cost) as cost_price,
    bis.minimum_stock,
    bis.last_received_at,
    o.name as branch_name
FROM items i
LEFT JOIN branch_item_stock bis ON i.cloud_id = bis.item_id
LEFT JOIN organizations o ON bis.organization_id = o.cloud_id::TEXT
WHERE i.master_item_id IS NULL  -- Only master items
  AND i.is_active = TRUE;

-- ============================================================================
-- STEP 7: Function to initialize branch stock from master catalog
-- ============================================================================

CREATE OR REPLACE FUNCTION initialize_branch_stock(branch_id TEXT)
RETURNS INTEGER AS $$
DECLARE
    commissary_id UUID;
    inserted_count INTEGER := 0;
BEGIN
    -- Get the parent commissary for this branch
    SELECT parent_commissary_id INTO commissary_id
    FROM organizations
    WHERE cloud_id::TEXT = branch_id;
    
    IF commissary_id IS NULL THEN
        RAISE EXCEPTION 'Branch % has no parent commissary', branch_id;
    END IF;
    
    -- Insert stock records for all master items from commissary
    INSERT INTO branch_item_stock (organization_id, item_id, stock, created_at, last_updated)
    SELECT 
        branch_id,
        i.cloud_id,
        0,  -- Start with zero stock
        NOW(),
        NOW()
    FROM items i
    WHERE i.organization_id = commissary_id
      AND i.master_item_id IS NULL  -- Master items only
      AND i.is_active = TRUE
      AND NOT EXISTS (
          SELECT 1 FROM branch_item_stock bis
          WHERE bis.organization_id = branch_id
            AND bis.item_id = i.cloud_id
      );
    
    GET DIAGNOSTICS inserted_count = ROW_COUNT;
    RETURN inserted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- STEP 8: Trigger to auto-create branch stock when new master item is added
-- ============================================================================

CREATE OR REPLACE FUNCTION create_branch_stock_for_new_item()
RETURNS TRIGGER AS $$
BEGIN
    -- Only for master items (from commissary)
    IF NEW.master_item_id IS NULL THEN
        -- Create stock records for all franchisees under this commissary
        INSERT INTO branch_item_stock (organization_id, item_id, stock, created_at, last_updated)
        SELECT 
            o.cloud_id::TEXT,
            NEW.cloud_id,
            0,
            NOW(),
            NOW()
        FROM organizations o
        WHERE o.parent_commissary_id = NEW.organization_id
          AND o.is_active = TRUE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_create_branch_stock ON items;
CREATE TRIGGER trigger_create_branch_stock
    AFTER INSERT ON items
    FOR EACH ROW
    EXECUTE FUNCTION create_branch_stock_for_new_item();

-- ============================================================================
-- STEP 9: Indexes for performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_items_org_master ON items(organization_id, master_item_id);
CREATE INDEX IF NOT EXISTS idx_daily_sales_org_date ON daily_sales_summary(organization_id, summary_date);
CREATE INDEX IF NOT EXISTS idx_daily_sales_item ON daily_sales_summary(item_id);

-- ============================================================================
-- DONE
-- ============================================================================
-- After running this migration:
-- 1. Master items stay in 'items' table (created by commissary)
-- 2. Each branch has 'branch_item_stock' records for their inventory
-- 3. Sales are tracked per-branch in 'daily_sales_summary'
-- 4. Franchisees automatically get stock records when commissary adds items
-- ============================================================================
