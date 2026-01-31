-- ============================================================================
-- Add missing columns to items table
-- ============================================================================
-- Add all missing columns to match local Drift schema

-- Add cost_price column (for franchisee profit margin tracking)
ALTER TABLE items ADD COLUMN IF NOT EXISTS cost_price DECIMAL(10, 2);

-- Add is_deleted column (for soft delete functionality)
ALTER TABLE items ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

-- Add category_id column (for item categorization)
ALTER TABLE items ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(cloud_id) ON DELETE SET NULL;

-- Add minimum_stock column (for low stock alerts)
ALTER TABLE items ADD COLUMN IF NOT EXISTS minimum_stock INTEGER;

-- Add unit column (for measurement unit)
ALTER TABLE items ADD COLUMN IF NOT EXISTS unit VARCHAR(50) DEFAULT 'piece';

-- Add comments for documentation
COMMENT ON COLUMN items.cost_price IS 'Cost per unit (for franchisee to know their cost from commissary)';
COMMENT ON COLUMN items.is_deleted IS 'Soft delete flag - items are marked deleted instead of being removed';
COMMENT ON COLUMN items.category_id IS 'Optional category for filtering items';
COMMENT ON COLUMN items.minimum_stock IS 'Minimum stock threshold for low stock alerts';
COMMENT ON COLUMN items.unit IS 'Unit of measurement (e.g., piece, serving, box)';
