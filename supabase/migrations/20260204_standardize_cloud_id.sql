    -- Migration: Standardize UUID columns to use cloud_id
    -- Date: 2026-02-04
    -- Purpose: Ensure all tables have consistent cloud_id column for sync

    -- ============================================================================
    -- STEP 1: Add cloud_id column to roles table (if it doesn't exist)
    -- ============================================================================

    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'roles' 
            AND column_name = 'cloud_id'
        ) THEN
            -- Add cloud_id column
            ALTER TABLE public.roles ADD COLUMN cloud_id TEXT;
            
            -- Generate UUIDs for existing rows
            UPDATE public.roles SET cloud_id = gen_random_uuid()::text WHERE cloud_id IS NULL;
            
            -- Make cloud_id NOT NULL and UNIQUE
            ALTER TABLE public.roles ALTER COLUMN cloud_id SET NOT NULL;
            ALTER TABLE public.roles ADD CONSTRAINT roles_cloud_id_key UNIQUE (cloud_id);
            
            -- Create index for faster lookups
            CREATE INDEX IF NOT EXISTS idx_roles_cloud_id ON public.roles(cloud_id);
            
            RAISE NOTICE 'Added cloud_id column to roles table';
        ELSE
            RAISE NOTICE 'roles.cloud_id already exists';
        END IF;
    END $$;

    -- ============================================================================
    -- STEP 2: Add last_updated column to roles if missing (needed for sync)
    -- ============================================================================

    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'roles' 
            AND column_name = 'last_updated'
        ) THEN
            ALTER TABLE public.roles ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
            UPDATE public.roles SET last_updated = COALESCE(updated_at, created_at, NOW());
            RAISE NOTICE 'Added last_updated to roles';
        END IF;
    END $$;

    -- ============================================================================
    -- STEP 3: Ensure other key tables have cloud_id (verification)
    -- ============================================================================

    -- Verify organizations has cloud_id
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'organizations' 
            AND column_name = 'cloud_id'
        ) THEN
            ALTER TABLE public.organizations ADD COLUMN cloud_id TEXT DEFAULT gen_random_uuid()::text NOT NULL;
            ALTER TABLE public.organizations ADD CONSTRAINT organizations_cloud_id_key UNIQUE (cloud_id);
            CREATE INDEX IF NOT EXISTS idx_organizations_cloud_id ON public.organizations(cloud_id);
            RAISE NOTICE 'Added cloud_id to organizations';
        END IF;
    END $$;

    -- Verify users has cloud_id
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'users' 
            AND column_name = 'cloud_id'
        ) THEN
            ALTER TABLE public.users ADD COLUMN cloud_id TEXT DEFAULT gen_random_uuid()::text NOT NULL;
            ALTER TABLE public.users ADD CONSTRAINT users_cloud_id_key UNIQUE (cloud_id);
            CREATE INDEX IF NOT EXISTS idx_users_cloud_id ON public.users(cloud_id);
            RAISE NOTICE 'Added cloud_id to users';
        END IF;
    END $$;

    -- Verify items has cloud_id
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'items' 
            AND column_name = 'cloud_id'
        ) THEN
            ALTER TABLE public.items ADD COLUMN cloud_id TEXT DEFAULT gen_random_uuid()::text NOT NULL;
            ALTER TABLE public.items ADD CONSTRAINT items_cloud_id_key UNIQUE (cloud_id);
            CREATE INDEX IF NOT EXISTS idx_items_cloud_id ON public.items(cloud_id);
            RAISE NOTICE 'Added cloud_id to items';
        END IF;
    END $$;

    -- Verify ingredients has cloud_id
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'ingredients' 
            AND column_name = 'cloud_id'
        ) THEN
            ALTER TABLE public.ingredients ADD COLUMN cloud_id TEXT DEFAULT gen_random_uuid()::text NOT NULL;
            ALTER TABLE public.ingredients ADD CONSTRAINT ingredients_cloud_id_key UNIQUE (cloud_id);
            CREATE INDEX IF NOT EXISTS idx_ingredients_cloud_id ON public.ingredients(cloud_id);
            RAISE NOTICE 'Added cloud_id to ingredients';
        END IF;
    END $$;

    -- ============================================================================
    -- STEP 4: Create trigger to auto-update last_updated on changes
    -- ============================================================================

    CREATE OR REPLACE FUNCTION update_last_updated_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.last_updated = NOW();
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    -- Apply trigger to roles table
    DROP TRIGGER IF EXISTS trigger_update_last_updated ON public.roles;
    CREATE TRIGGER trigger_update_last_updated
        BEFORE UPDATE ON public.roles
        FOR EACH ROW
        EXECUTE FUNCTION update_last_updated_column();

    -- ============================================================================
    -- STEP 5: Verify the migration
    -- ============================================================================

    SELECT 
        table_name,
        column_name,
        data_type,
        is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND column_name = 'cloud_id'
    ORDER BY table_name;
