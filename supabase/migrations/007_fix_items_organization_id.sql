-- ============================================================================
-- FIX ITEMS organization_id: Change from INTEGER to UUID
-- ============================================================================
-- Previous sync code was pushing local integer IDs (1, 2, etc.) instead of
-- organization cloud_id (UUID). This migration fixes the column type and
-- converts existing data.
-- ============================================================================

-- Step 1: Add a new UUID column
ALTER TABLE items ADD COLUMN IF NOT EXISTS organization_id_new UUID;

-- Step 2: Map integer values to UUIDs
-- You need to replace these UUIDs with your actual organization cloud_ids
-- Run: SELECT cloud_id, name FROM organizations; to get the mapping

-- organization_id = 1 → Main Commissary (replace with actual UUID)
UPDATE items SET organization_id_new = '65c32d14-9537-436f-8ab9-0f3e58b06744'::UUID 
WHERE organization_id::TEXT = '1' AND organization_id_new IS NULL;

-- organization_id = 2 → ChickenJoo - Taguig (replace with actual UUID)
UPDATE items SET organization_id_new = 'da017cd1-6052-4051-8236-9040904e220f'::UUID 
WHERE organization_id::TEXT = '2' AND organization_id_new IS NULL;

-- organization_id = 3 → ChickenJoo - SM Bicutan (replace with actual UUID)
UPDATE items SET organization_id_new = 'fb490767-96b3-408f-9d80-ab496295d75f'::UUID 
WHERE organization_id::TEXT = '3' AND organization_id_new IS NULL;

-- Step 3: Drop old column and rename new one
ALTER TABLE items DROP COLUMN organization_id;
ALTER TABLE items RENAME COLUMN organization_id_new TO organization_id;

-- Step 4: Add NOT NULL constraint
ALTER TABLE items ALTER COLUMN organization_id SET NOT NULL;

-- Step 5: Add index for performance
CREATE INDEX IF NOT EXISTS idx_items_organization_id ON items(organization_id);

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- After running, verify with:
-- SELECT name, organization_id, cloud_id FROM items;
-- 
-- organization_id should now be UUIDs like:
-- '65c32d14-9537-436f-8ab9-0f3e58b06744'
-- ============================================================================
