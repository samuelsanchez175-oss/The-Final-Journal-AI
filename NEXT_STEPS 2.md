# Next Steps After Database Setup ✅

Great! Your database table is created. Now let's finish the Supabase integration.

## Step 1: Add Supabase Swift SDK to Xcode

### Option A: Using Xcode UI (Recommended)

1. **Open your project in Xcode**
   - Open `The Final Journal AI.xcodeproj` or `XJournal AI.xcodeproj`

2. **Add Package Dependency**
   - In Xcode menu: **File** → **Add Package Dependencies...**
   - Or: Click on your project in the navigator → Select your app target → Go to **"Package Dependencies"** tab → Click **"+"** button

3. **Enter Package URL**
   - Paste this URL: `https://github.com/supabase/supabase-swift`
   - Click **"Add Package"**

4. **Select Version**
   - Choose **"Up to Next Major Version"** with version **2.0.0** or higher
   - Click **"Add Package"**

5. **Add to Target**
   - Make sure **"The Final Journal AI"** target is checked
   - Click **"Add Package"**

6. **Wait for download**
   - Xcode will download and integrate the package (takes ~30 seconds)

### Option B: Verify Package Was Added

- In Xcode, you should see **"Package Dependencies"** in the Project Navigator
- You should see `supabase-swift` listed there

---

## Step 2: Enable Supabase Code

Now we need to uncomment the Supabase code in `AccountManager.swift`:

1. **Open** `XJournal AI/AccountManager.swift` in Xcode

2. **Find and uncomment** these sections (remove the `/*` and `*/`):
   - Look for: `// Uncomment when Supabase SDK is added:`
   - Remove the comment blocks around Supabase code

3. **Remove mock fallback** (optional):
   - You can remove the `mockSignUp` and `mockSignIn` functions if you want
   - Or keep them as fallback for testing

**Quick way to do this:**
- In Xcode, press `Cmd+F` (Find)
- Search for: `Uncomment when Supabase SDK is added`
- You'll see several instances - uncomment each block

---

## Step 3: Enable Email Authentication in Supabase

1. **Go to Supabase Dashboard**
   - Visit [https://app.supabase.com](https://app.supabase.com)
   - Open your project

2. **Go to Authentication Settings**
   - Click **"Authentication"** in the left sidebar
   - Click **"Providers"** tab

3. **Enable Email Provider**
   - Find **"Email"** in the list
   - Toggle it **ON** (should turn blue/green)
   - Click **"Save"** if there's a save button

4. **Configure Email Settings** (Optional but recommended)
   - You can customize email templates for:
     - Sign up confirmation
     - Password reset
     - Magic link
   - For now, default settings are fine

---

## Step 4: Update AccountManager.swift Import

1. **Open** `XJournal AI/AccountManager.swift`

2. **Find the import section** at the top (around line 1-3)

3. **Uncomment this line:**
   ```swift
   import Supabase
   ```
   (Remove the `//` comment)

---

## Step 5: Test the Integration

1. **Build the project**
   - Press `Cmd+B` in Xcode
   - Make sure there are no errors

2. **Run the app**
   - Press `Cmd+R` to run
   - Or click the Play button

3. **Test Sign Up**
   - Go to Profile page (person icon)
   - Click **"Create Account"**
   - Enter:
     - Name: Your name
     - Email: Your email
     - Password: At least 8 characters
     - Confirm Password: Same password
   - Click **"Create Account"**
   - Should sign you in automatically!

4. **Test Sign In**
   - Sign out (if signed in)
   - Click **"Sign In"**
   - Enter your email and password
   - Should sign you in!

5. **Test Data Sync**
   - After signing in, update your profile (name, email, etc.)
   - Click **"Save"**
   - Click **"Sync to Cloud"** button
   - Should sync successfully!

---

## Troubleshooting

### "Cannot find 'Supabase' in scope"
- Make sure you added the package dependency
- Try: **File** → **Packages** → **Reset Package Caches**
- Clean build folder: **Product** → **Clean Build Folder** (`Cmd+Shift+K`)

### "Supabase not configured" warning
- Check `SupabaseConfig.swift` has your correct URL and key
- Make sure `isConfigured` returns `true`

### Authentication errors
- Make sure Email provider is enabled in Supabase dashboard
- Check that your project is active (not paused)

### Build errors
- Make sure you uncommented the `import Supabase` line
- Make sure you uncommented all the Supabase code blocks
- Try cleaning build folder and rebuilding

---

## What Should Work Now

✅ Sign up with email/password  
✅ Sign in with email/password  
✅ Sign out  
✅ Auto-sync profile data after sign up  
✅ Auto-load profile data after sign in  
✅ Manual sync/load buttons  
✅ Secure token storage in Keychain  

---

## Next Steps (Optional)

- Add social logins (Google, Apple) in Supabase → Authentication → Providers
- Customize email templates
- Add password reset functionality
- Sync journal entries (requires additional tables)

---

**Need help?** Let me know if you run into any errors or issues!
