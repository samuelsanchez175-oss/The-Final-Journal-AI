# Step-by-Step: Setting Up the Database Table in Supabase

This guide will walk you through creating the database table needed to store user profile data.

## What You're Creating

A table called `user_profiles` that will store:
- User ID (links to the authenticated user)
- Profile data (name, email, preferences, settings, etc.)
- Timestamps (when created/updated)

## Step-by-Step Instructions

### Step 1: Open Supabase Dashboard

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in to your account
3. Click on your project: **fmzkmerqotgisspgjhyj**

### Step 2: Open SQL Editor

1. In the left sidebar, look for **"SQL Editor"** (it has a `</>` icon)
2. Click on **"SQL Editor"**
3. You should see a blank editor window

### Step 3: Copy the SQL Code

Copy this entire block of code:

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

### Step 4: Paste and Run

1. **Paste** the code into the SQL Editor window
2. Click the **"Run"** button (or press `Cmd+Enter` on Mac / `Ctrl+Enter` on Windows)
3. Wait a few seconds...

### Step 5: Verify It Worked

You should see a success message like:
- ✅ "Success. No rows returned"
- Or a green checkmark

### Step 6: Verify the Table Exists

1. In the left sidebar, click on **"Table Editor"** (has a table icon)
2. You should see a list of tables
3. Look for **`user_profiles`** in the list
4. If you see it, you're done! ✅

## What This SQL Does (Simple Explanation)

1. **Creates the table** - Makes a new table called `user_profiles`
2. **Sets up security** - Ensures users can only see/edit their own data
3. **Adds timestamps** - Automatically tracks when data is created/updated

## Troubleshooting

### "Error: relation already exists"
- This means the table already exists - that's okay! You can skip this step.

### "Error: permission denied"
- Make sure you're logged into the correct Supabase project
- Try refreshing the page and running again

### "Error: syntax error"
- Make sure you copied the entire SQL block
- Check that there are no extra characters at the beginning/end

### Can't find SQL Editor?
- Look in the left sidebar menu
- It might be under "Database" → "SQL Editor"
- Or use the search bar at the top to find "SQL Editor"

## Alternative: Using Table Editor (Visual Method)

If you prefer a visual interface instead of SQL:

1. Go to **Table Editor** in the left sidebar
2. Click **"New Table"**
3. Name it: `user_profiles`
4. Add these columns:
   - `id` - Type: `uuid`, Primary Key: Yes, Default: `gen_random_uuid()`
   - `user_id` - Type: `uuid`, Unique: Yes, Foreign Key: `auth.users(id)`
   - `profile_data` - Type: `jsonb`
   - `created_at` - Type: `timestamptz`, Default: `now()`
   - `updated_at` - Type: `timestamptz`, Default: `now()`
5. Click **"Save"**
6. Then go to **Authentication** → **Policies** to set up Row Level Security

**Note:** The SQL method is faster and sets everything up at once!

## Need Help?

If you're still stuck, let me know what error message you're seeing or where you're getting confused!
