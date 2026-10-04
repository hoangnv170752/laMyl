-- laMyl Supabase Database Schema
-- Self-managed users (no Supabase Auth)
-- Run this in Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- DROP existing tables (in correct order due to foreign keys)
-- ============================================
DROP TABLE IF EXISTS custom_sounds CASCADE;
DROP TABLE IF EXISTS key_stats CASCADE;
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS public.create_user_with_defaults(TEXT, TEXT);
DROP FUNCTION IF EXISTS public.get_or_create_user(TEXT, TEXT);
DROP FUNCTION IF EXISTS public.update_updated_at();

-- ============================================
-- Table: profiles
-- User profile information (self-managed)
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    display_name TEXT,
    is_anonymous BOOLEAN DEFAULT true NOT NULL,
    -- RevenueCat user ID for subscription verification
    revenuecat_user_id TEXT,
    -- Device identifier for linking
    device_id TEXT
);

-- Index for lookups
CREATE INDEX IF NOT EXISTS idx_profiles_device_id ON profiles(device_id);
CREATE INDEX IF NOT EXISTS idx_profiles_revenuecat_user_id ON profiles(revenuecat_user_id);

-- ============================================
-- Table: user_settings
-- User preferences and settings
-- ============================================
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    volume FLOAT DEFAULT 0.7 NOT NULL CHECK (volume >= 0 AND volume <= 1),
    is_enabled BOOLEAN DEFAULT true NOT NULL,
    low_volume_boost BOOLEAN DEFAULT false NOT NULL,
    launch_at_login BOOLEAN DEFAULT false NOT NULL,
    selected_sound TEXT DEFAULT 'default' NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id)
);

-- ============================================
-- Table: key_stats
-- Keyboard usage statistics
-- ============================================
CREATE TABLE key_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    total_keys BIGINT DEFAULT 0 NOT NULL,
    daily_keys JSONB DEFAULT '{}' NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id)
);

-- ============================================
-- Table: custom_sounds
-- User-created sound profiles
-- ============================================
CREATE TABLE custom_sounds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    is_favorite BOOLEAN DEFAULT false NOT NULL,
    sound_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================
-- RLS Policies (using anon key with service role bypass)
-- For production, use service_role key on server or
-- implement JWT verification
-- ============================================

-- Disable RLS for now (using anon key with full access)
-- In production, you should:
-- 1. Use Edge Functions with service_role key, or
-- 2. Implement custom JWT verification

ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE key_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE custom_sounds DISABLE ROW LEVEL SECURITY;

-- Alternative: Enable RLS with permissive policies for anon
-- Uncomment below if you want basic RLS

-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow all for anon" ON profiles FOR ALL USING (true);
--
-- ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow all for anon" ON user_settings FOR ALL USING (true);
--
-- ALTER TABLE key_stats ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow all for anon" ON key_stats FOR ALL USING (true);
--
-- ALTER TABLE custom_sounds ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow all for anon" ON custom_sounds FOR ALL USING (true);

-- ============================================
-- Functions
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS update_user_settings_updated_at ON user_settings;
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS update_key_stats_updated_at ON key_stats;
CREATE TRIGGER update_key_stats_updated_at
    BEFORE UPDATE ON key_stats
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Function to create user with all related records
CREATE OR REPLACE FUNCTION public.create_user_with_defaults(
    p_device_id TEXT DEFAULT NULL,
    p_revenuecat_user_id TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
BEGIN
    -- Create profile
    INSERT INTO profiles (device_id, revenuecat_user_id)
    VALUES (p_device_id, p_revenuecat_user_id)
    RETURNING id INTO new_user_id;

    -- Create default settings
    INSERT INTO user_settings (user_id)
    VALUES (new_user_id);

    -- Initialize key stats
    INSERT INTO key_stats (user_id)
    VALUES (new_user_id);

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get or create user by device ID
CREATE OR REPLACE FUNCTION public.get_or_create_user(
    p_device_id TEXT,
    p_revenuecat_user_id TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    existing_user_id UUID;
BEGIN
    -- Try to find existing user
    SELECT id INTO existing_user_id
    FROM profiles
    WHERE device_id = p_device_id
    LIMIT 1;

    -- If found, update revenuecat_user_id if provided
    IF existing_user_id IS NOT NULL THEN
        IF p_revenuecat_user_id IS NOT NULL THEN
            UPDATE profiles
            SET revenuecat_user_id = p_revenuecat_user_id
            WHERE id = existing_user_id;
        END IF;
        RETURN existing_user_id;
    END IF;

    -- Create new user
    RETURN public.create_user_with_defaults(p_device_id, p_revenuecat_user_id);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_key_stats_user_id ON key_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_sounds_user_id ON custom_sounds(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_sounds_is_favorite ON custom_sounds(user_id, is_favorite);

-- ============================================
-- Usage Examples
-- ============================================
--
-- Create new user:
-- SELECT public.create_user_with_defaults('device-abc-123', 'rc_user_456');
--
-- Get or create user:
-- SELECT public.get_or_create_user('device-abc-123');
--
-- Upsert settings:
-- INSERT INTO user_settings (user_id, volume, is_enabled)
-- VALUES ('uuid-here', 0.8, true)
-- ON CONFLICT (user_id) DO UPDATE SET
--     volume = EXCLUDED.volume,
--     is_enabled = EXCLUDED.is_enabled;
