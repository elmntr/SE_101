-- ============================================================================
-- MIGRATION 005: Add Daily Sales Summary and Branch Ingredient Stock Tables
-- ============================================================================
-- Purpose:
-- 1. DailySalesSummary - Storage-efficient aggregated sales data per branch/item/day
-- 2. BranchIngredientStock - Per-branch ingredient inventory tracking
-- 
-- NOTE: Uses TEXT for foreign keys to match existing tables where cloud_id is TEXT
-- ============================================================================

-- ============================================================================
-- STEP 1: Create daily_sales_summary table
-- ============================================================================

CREATE TABLE IF NOT EXISTS daily_sales_summary (
    -- Primary identifier (UUID for cloud)
    cloud_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign keys (TEXT to match existing tables' cloud_id type)
    organization_id TEXT NOT NULL,
    item_id TEXT NOT NULL,
    
    -- The date this summary covers (date only, no time)
    summary_date DATE NOT NULL,
    
    -- Sales metrics
    quantity_sold INTEGER NOT NULL DEFAULT 0,
    quantity_spoiled INTEGER NOT NULL DEFAULT 0,
    revenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    cost_of_goods_sold DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    gross_profit DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    transaction_count INTEGER NOT NULL DEFAULT 0,
    
    -- Stock reconciliation
    opening_stock INTEGER,
    closing_stock INTEGER,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one summary per item per branch per day
    UNIQUE(organization_id, item_id, summary_date)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_daily_sales_org_date 
    ON daily_sales_summary(organization_id, summary_date);
CREATE INDEX IF NOT EXISTS idx_daily_sales_item_date 
    ON daily_sales_summary(item_id, summary_date);
CREATE INDEX IF NOT EXISTS idx_daily_sales_date 
    ON daily_sales_summary(summary_date);

-- ============================================================================
-- STEP 2: Create branch_ingredient_stock table
-- ============================================================================

CREATE TABLE IF NOT EXISTS branch_ingredient_stock (
    -- Primary identifier (UUID for cloud)
    cloud_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign keys (TEXT to match existing tables' cloud_id type)
    organization_id TEXT NOT NULL,
    ingredient_id TEXT NOT NULL,
    
    -- Stock data
    quantity DECIMAL(12,3) NOT NULL DEFAULT 0.000,
    minimum_stock DECIMAL(12,3),
    
    -- Delivery tracking
    last_received_at TIMESTAMPTZ,
    last_received_quantity DECIMAL(12,3),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one stock record per ingredient per branch
    UNIQUE(organization_id, ingredient_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_branch_ing_stock_org 
    ON branch_ingredient_stock(organization_id);
CREATE INDEX IF NOT EXISTS idx_branch_ing_stock_ingredient 
    ON branch_ingredient_stock(ingredient_id);

-- ============================================================================
-- STEP 3: Enable Row Level Security
-- ============================================================================

ALTER TABLE daily_sales_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE branch_ingredient_stock ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 4: RLS Policies for daily_sales_summary
-- ============================================================================

-- Commissary can view ALL sales summaries (for network-wide reporting)
CREATE POLICY "Commissary can view all sales summaries"
    ON daily_sales_summary
    FOR SELECT
    USING (is_commissary_user());

-- Branches can view/manage their own sales summaries
-- Note: Cast UUID to TEXT for comparison since organization_id is TEXT
CREATE POLICY "Branches can view own sales summaries"
    ON daily_sales_summary
    FOR SELECT
    USING (organization_id = get_current_user_organization_id()::TEXT);

CREATE POLICY "Branches can insert own sales summaries"
    ON daily_sales_summary
    FOR INSERT
    WITH CHECK (organization_id = get_current_user_organization_id()::TEXT);

CREATE POLICY "Branches can update own sales summaries"
    ON daily_sales_summary
    FOR UPDATE
    USING (organization_id = get_current_user_organization_id()::TEXT)
    WITH CHECK (organization_id = get_current_user_organization_id()::TEXT);

-- ============================================================================
-- STEP 5: RLS Policies for branch_ingredient_stock
-- ============================================================================

-- Commissary can view ALL branch ingredient stocks
CREATE POLICY "Commissary can view all branch ingredient stocks"
    ON branch_ingredient_stock
    FOR SELECT
    USING (is_commissary_user());

-- Commissary can insert stock when distributing to branches
CREATE POLICY "Commissary can insert branch ingredient stocks"
    ON branch_ingredient_stock
    FOR INSERT
    WITH CHECK (is_commissary_user() OR organization_id = get_current_user_organization_id()::TEXT);

-- Branches can view their own ingredient stocks
CREATE POLICY "Branches can view own ingredient stocks"
    ON branch_ingredient_stock
    FOR SELECT
    USING (organization_id = get_current_user_organization_id()::TEXT);

-- Branches can update their own ingredient stocks
CREATE POLICY "Branches can update own ingredient stocks"
    ON branch_ingredient_stock
    FOR UPDATE
    USING (organization_id = get_current_user_organization_id()::TEXT)
    WITH CHECK (organization_id = get_current_user_organization_id()::TEXT);

-- ============================================================================
-- STEP 6: Helper views for commissary dashboard (optional, for convenience)
-- ============================================================================

-- View: Network-wide daily sales totals
CREATE OR REPLACE VIEW network_daily_sales AS
SELECT 
    summary_date,
    SUM(quantity_sold) as total_sold,
    SUM(quantity_spoiled) as total_spoiled,
    SUM(revenue) as total_revenue,
    SUM(cost_of_goods_sold) as total_cost,
    SUM(gross_profit) as total_profit,
    SUM(transaction_count) as total_transactions,
    COUNT(DISTINCT organization_id) as active_branches
FROM daily_sales_summary
GROUP BY summary_date
ORDER BY summary_date DESC;

-- View: Sales by branch
CREATE OR REPLACE VIEW branch_sales_summary AS
SELECT 
    o.cloud_id::TEXT as organization_id,
    o.name as branch_name,
    dss.summary_date,
    SUM(dss.quantity_sold) as total_sold,
    SUM(dss.revenue) as total_revenue,
    SUM(dss.gross_profit) as total_profit
FROM daily_sales_summary dss
JOIN organizations o ON dss.organization_id = o.cloud_id::TEXT
GROUP BY o.cloud_id, o.name, dss.summary_date
ORDER BY dss.summary_date DESC, total_revenue DESC;

-- View: Low stock ingredients across branches
CREATE OR REPLACE VIEW low_stock_ingredients AS
SELECT 
    o.name as branch_name,
    i.name as ingredient_name,
    bis.quantity,
    bis.minimum_stock,
    (bis.minimum_stock - bis.quantity) as units_below_minimum
FROM branch_ingredient_stock bis
JOIN organizations o ON bis.organization_id = o.cloud_id::TEXT
JOIN ingredients i ON bis.ingredient_id = i.cloud_id::TEXT
WHERE bis.minimum_stock IS NOT NULL 
  AND bis.quantity < bis.minimum_stock
ORDER BY units_below_minimum DESC;

-- ============================================================================
-- STEP 7: Realtime subscription setup
-- ============================================================================

-- Enable realtime for stock_change_requests (for live sales feed)
-- Note: This may already be enabled, but ensures it's on
ALTER PUBLICATION supabase_realtime ADD TABLE stock_change_requests;

-- Enable realtime for daily_sales_summary (for dashboard updates)
ALTER PUBLICATION supabase_realtime ADD TABLE daily_sales_summary;

-- ============================================================================
-- DONE
-- ============================================================================
