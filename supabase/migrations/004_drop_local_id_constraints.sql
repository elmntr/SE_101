-- ============================================================================
-- DROP local_id UNIQUE CONSTRAINTS
-- ============================================================================
-- The local_id column is only meaningful on the local device.
-- Different devices can have the same local_id for different records.
-- Only cloud_id should be unique.
-- ============================================================================

-- Drop unique constraints on local_id for all tables
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_local_id_unique;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_local_id_key;

ALTER TABLE organizations DROP CONSTRAINT IF EXISTS organizations_local_id_unique;
ALTER TABLE organizations DROP CONSTRAINT IF EXISTS organizations_local_id_key;

ALTER TABLE roles DROP CONSTRAINT IF EXISTS roles_local_id_unique;
ALTER TABLE roles DROP CONSTRAINT IF EXISTS roles_local_id_key;

ALTER TABLE items DROP CONSTRAINT IF EXISTS items_local_id_unique;
ALTER TABLE items DROP CONSTRAINT IF EXISTS items_local_id_key;

ALTER TABLE ingredients DROP CONSTRAINT IF EXISTS ingredients_local_id_unique;
ALTER TABLE ingredients DROP CONSTRAINT IF EXISTS ingredients_local_id_key;

ALTER TABLE recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_local_id_unique;
ALTER TABLE recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_local_id_key;

ALTER TABLE stock_replenishment_requests DROP CONSTRAINT IF EXISTS stock_replenishment_requests_local_id_unique;
ALTER TABLE stock_replenishment_requests DROP CONSTRAINT IF EXISTS stock_replenishment_requests_local_id_key;

ALTER TABLE stock_change_requests DROP CONSTRAINT IF EXISTS stock_change_requests_local_id_unique;
ALTER TABLE stock_change_requests DROP CONSTRAINT IF EXISTS stock_change_requests_local_id_key;

-- Also drop any unique indexes on local_id
DROP INDEX IF EXISTS idx_users_local_id;
DROP INDEX IF EXISTS idx_organizations_local_id;
DROP INDEX IF EXISTS idx_roles_local_id;
DROP INDEX IF EXISTS idx_items_local_id;
DROP INDEX IF EXISTS idx_ingredients_local_id;
DROP INDEX IF EXISTS idx_recipe_ingredients_local_id;
DROP INDEX IF EXISTS idx_stock_replenishment_requests_local_id;
DROP INDEX IF EXISTS idx_stock_change_requests_local_id;

-- Make local_id column nullable (since we no longer send it)
ALTER TABLE users ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE organizations ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE roles ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE items ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE ingredients ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE recipe_ingredients ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE stock_replenishment_requests ALTER COLUMN local_id DROP NOT NULL;
ALTER TABLE stock_change_requests ALTER COLUMN local_id DROP NOT NULL;

-- ============================================================================
-- DONE
-- ============================================================================
