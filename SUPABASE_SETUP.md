# Supabase Integration Setup Guide

This guide will help you set up Supabase authentication for The Final Journal AI app.

## Step 1: Create a Supabase Account

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project" and sign up (free)
3. Create a new project
4. Wait for the project to finish setting up (takes ~2 minutes)

## Step 2: Get Your Supabase Credentials

1. In your Supabase project dashboard, go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

## Step 3: Configure the App

1. Open `XJournal AI/SupabaseConfig.swift`
2. Replace the placeholder values:
   ```swift
   static let supabaseURL = "YOUR_SUPABASE_PROJECT_URL"
   static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
   ```

## Step 4: Add Supabase Swift SDK

### Option A: Using Xcode (Recommended)

1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. Enter this URL: `https://github.com/supabase/supabase-swift`
4. Select version: **Latest** (or a specific version like `2.0.0`)
5. Add the package to your target: **The Final Journal AI**
6. Click **Add Package**

### Option B: Using Swift Package Manager (Command Line)

If you prefer command line, add this to your `Package.swift` or use Xcode's package manager.

## Step 5: Uncomment Supabase Code

After adding the SDK, uncomment all the Supabase code in:
- `XJournal AI/AccountManager.swift` (look for `// Uncomment when Supabase SDK is added:`)

## Step 6: Set Up Database Tables

You'll need to create a table in Supabase to store user profile data:

1. Go to your Supabase project → **SQL Editor**
2. Run this SQL to create the `user_profiles` table:

```sql
-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  profile_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only read/write their own profile
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Step 7: Enable Email Authentication

1. Go to **Authentication** → **Providers** in Supabase dashboard
2. Enable **Email** provider
3. Configure email templates if desired (optional)

## Step 8: Test the Integration

1. Build and run the app
2. Go to Profile page
3. Click "Create Account" or "Sign In"
4. Test sign up and sign in flows

## What Gets Synced

When users sign in, the following data syncs to Supabase:

- **Profile Information**: Name, email, phone, avatar
- **Personal Details**: Locations, people, themes, interests, background
- **Model Settings**: Model G & Model Y configurations
- **User Preferences**: Personalization settings

## Security Notes

- The `anon` key is safe to use in client apps (it's public)
- Never expose the `service_role` key in client code
- Row Level Security (RLS) ensures users can only access their own data
- All data is encrypted in transit (HTTPS)

## Troubleshooting

### "Supabase not configured" warning
- Make sure you've updated `SupabaseConfig.swift` with your credentials
- Check that the URL and key are correct

### Authentication errors
- Verify email provider is enabled in Supabase dashboard
- Check that your project is active (free projects pause after 7 days of inactivity)

### Sync errors
- Make sure the `user_profiles` table exists in your database
- Check that RLS policies are set up correctly
- Verify the user is signed in before syncing

## Next Steps

- Add social logins (Google, Apple, GitHub) in Supabase dashboard
- Set up email templates for password reset
- Configure custom domains (requires paid plan)
- Add more tables for syncing journal entries (optional)

## Resources

- [Supabase Swift SDK Documentation](https://github.com/supabase/supabase-swift)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase Database Documentation](https://supabase.com/docs/guides/database)
