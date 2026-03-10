-- ============================================================================
-- Migration 013: Remove password hashes from cloud
-- ============================================================================
-- Problem:
--   Password hashes were being synced to Supabase. Offline password hashes
--   should be local-only — they serve no purpose in the cloud and represent
--   a security risk if the cloud DB is compromised.
--
-- Fix:
--   1. Null out all existing password values in the cloud users table.
--   2. Drop the password column entirely (offline auth uses local DB only).
-- ============================================================================

-- Drop the password column entirely (handles NOT NULL constraint implicitly)
ALTER TABLE public.users DROP COLUMN IF EXISTS password;
