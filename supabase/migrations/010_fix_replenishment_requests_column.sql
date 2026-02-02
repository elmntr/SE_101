-- ============================================================================
-- MIGRATION 010: Fix stock_replenishment_requests last_updated column
-- ============================================================================
-- Purpose: Ensure stock_replenishment_requests has last_updated column
-- and fix any triggers that might reference updated_at
-- ============================================================================

-- Add last_updated to stock_replenishment_requests table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'stock_replenishment_requests' AND column_name = 'last_updated'
    ) THEN
        ALTER TABLE stock_replenishment_requests ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
        
        -- Update existing rows
        UPDATE stock_replenishment_requests 
        SET last_updated = COALESCE(created_at, NOW()) 
        WHERE last_updated IS NULL;
    END IF;
END $$;

-- Drop ALL triggers that might reference updated_at (this is the broken one!)
DROP TRIGGER IF EXISTS set_updated_at ON stock_replenishment_requests;
DROP TRIGGER IF EXISTS update_updated_at ON stock_replenishment_requests;
DROP TRIGGER IF EXISTS update_timestamp ON stock_replenishment_requests;
DROP TRIGGER IF EXISTS stock_replenishment_requests_updated_at ON stock_replenishment_requests;

-- Create a proper trigger function for last_updated (if it doesn't exist)
CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update last_updated on any update
DROP TRIGGER IF EXISTS set_last_updated ON stock_replenishment_requests;
CREATE TRIGGER set_last_updated
    BEFORE UPDATE ON stock_replenishment_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_last_updated_column();

-- Verify column exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'stock_replenishment_requests' AND column_name = 'last_updated'
    ) THEN
        RAISE EXCEPTION 'last_updated column was not created on stock_replenishment_requests';
    END IF;
END $$;

SELECT 'Migration 010 complete: stock_replenishment_requests.last_updated column verified' as status;
