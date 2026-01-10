-- ============================================================================
-- MIGRATION 006: Add missing last_updated columns
-- ============================================================================
-- Purpose: Add last_updated column to tables that are missing it
-- ============================================================================

-- Add last_updated to items table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'items' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE items ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
        
        -- Update existing rows to use created_at as initial last_updated
        UPDATE items SET last_updated = COALESCE(created_at, NOW()) WHERE last_updated IS NULL;
    END IF;
END $$;

-- Add last_updated to ingredients table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ingredients' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE ingredients ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
        
        -- Update existing rows
        UPDATE ingredients SET last_updated = COALESCE(created_at, NOW()) WHERE last_updated IS NULL;
    END IF;
END $$;

-- Add last_updated to recipe_ingredients table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'recipe_ingredients' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE recipe_ingredients ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
        
        -- Update existing rows
        UPDATE recipe_ingredients SET last_updated = COALESCE(created_at, NOW()) WHERE last_updated IS NULL;
    END IF;
END $$;

-- Add last_updated to categories table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'categories' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE categories ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
        
        -- Update existing rows
        UPDATE categories SET last_updated = COALESCE(created_at, NOW()) WHERE last_updated IS NULL;
    END IF;
END $$;

-- Create indexes for efficient sync queries
CREATE INDEX IF NOT EXISTS idx_items_last_updated ON items(last_updated);
CREATE INDEX IF NOT EXISTS idx_ingredients_last_updated ON ingredients(last_updated);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_last_updated ON recipe_ingredients(last_updated);
CREATE INDEX IF NOT EXISTS idx_categories_last_updated ON categories(last_updated);

-- ============================================================================
-- DONE
-- ============================================================================
