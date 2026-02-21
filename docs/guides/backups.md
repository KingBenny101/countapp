# Cloud Backups

Countapp supports backing up your counters to GitHub Gists, allowing you to restore your data across multiple devices.

## Overview

The backup system uses GitHub Gists to store your counter data in a **secret (unlisted) gist**. This means:

- Your backup is not searchable on GitHub
- It doesn't appear on your public gist list
- Only you (and anyone with the direct URL) can access it
- The same GitHub account can restore backups on any device

## Prerequisites

You need a GitHub account to use cloud backups. If you don't have one, you can create a free account at [github.com](https://github.com).

## Creating a GitHub Personal Access Token

To enable backups, you need to create a Personal Access Token (PAT) that gives Countapp permission to create and manage gists on your behalf.

### Step-by-Step Instructions

1. **Go to GitHub Settings**
   - Navigate to [github.com/settings/tokens](https://github.com/settings/tokens)
   - Or: Click your profile picture → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token**
   - Click the **"Generate new token"** button
   - Select **"Generate new token (classic)"** from the dropdown

3. **Configure Token Settings**
   - **Note**: Give it a descriptive name like `Countapp Backup` so you remember what it's for
   - **Expiration**: Choose an expiration period
     - `No expiration` - Most convenient, token never expires
     - `90 days`, `1 year`, etc. - More secure, requires renewal
   - **Scopes**: Check **only** the `gist` checkbox
     - ✅ `gist` - Create and access gists (required)
     - ❌ Do not check any other permissions

4. **Generate Token**
   - Scroll to the bottom and click **"Generate token"**
   - **Important**: Copy the token immediately (it looks like `ghp_xxxxxxxxxxxxx`)
   - You won't be able to see it again after leaving the page

5. **Save the Token**
   - Store it somewhere safe (password manager recommended)
   - You'll need to enter it in Countapp

## Configuring Backups in Countapp

1. **Open the Backups Page**
   - Open the app drawer (tap the menu icon in the top-left)
   - Tap **"Backups"**

2. **Enter Your Token**
   - Paste your GitHub Personal Access Token into the **"Token"** field
   - The field is obscured (shows dots) for security
   - Your GitHub username will appear below the field if the token is valid
   - If you see an error, the token is invalid or expired

3. **Update Token Anytime**
   - You can change the token at any time by typing a new one
   - The token is saved automatically as you type

4. **(Advanced) Backup Gist File Name**
   - Go to **Options** → **"Backup Gist File Name"**
   - This setting controls which file key inside your gist Countapp reads/writes
   - You usually do **not** need to change this
   - Only change it if you understand gist file structure and intentionally want a different backup file

## Using Backups

### Upload Backup

Creates a backup of all your counters and uploads it to your secret GitHub gist.

1. Tap the **upload icon** (↑) next to "Upload Backup"
2. Wait for the success message
3. Your counters are now backed up to GitHub

**Note**: Each upload overwrites the previous backup (only one backup exists at a time).

### Download Backup

Restores counters from your GitHub gist backup.

1. Tap the **download icon** (↓) next to "Download Backup"
2. If your local data is newer than the backup, you'll see a confirmation dialog
3. Confirm to proceed with the restore
4. Your counters will be replaced with the backup data

**Warning**: Download/restore is destructive - it will replace all your current counters with the backed-up ones.

### Auto-Backup on App Start

You can enable automatic backups every time you open the app.

1. Go to **Options** (from the app drawer)
2. Enable **"Backup on App Start"**
3. Backups will automatically upload when you launch Countapp

**Requirements**:

- You must have entered a valid GitHub token
- Auto-backup runs in the background and won't block app startup
- If the backup fails (network issue, invalid token), the app continues normally

## Cross-Device Sync

To use the same backup on multiple devices:

1. **On Device A**:
   - Enter your GitHub token
   - Upload a backup

2. **On Device B** (fresh install or different device):
   - Enter the **same GitHub token**
   - Tap "Download Backup"
   - Your counters from Device A will be restored

3. **Keep devices in sync**:
   - Enable "Backup on App Start" on all devices
   - The most recent device to open the app will get the latest data

## Troubleshooting

### "Invalid or expired token" error

**Solution**: Your token has expired or is incorrect.

- Go to [github.com/settings/tokens](https://github.com/settings/tokens)
- Delete the old token
- Create a new one following the instructions above

### "Not authenticated" error

**Solution**: You haven't entered a GitHub token yet.

- Go to the Backups page
- Enter a valid Personal Access Token

### "Failed to upload/download" error

**Solution**: Network or connectivity issue.

- Check your internet connection
- Try again in a few moments
- If the problem persists, check if GitHub is accessible

### Username doesn't appear

**Solution**: Token doesn't have the correct permissions.

- Make sure you selected **"Tokens (classic)"** not "Fine-grained tokens"
- Make sure you checked the `gist` scope when creating the token
- Create a new token if needed

## Security & Privacy

### What's Backed Up?

- ✅ All counters (values, names, types, settings)
- ❌ App settings (theme, etc.)
- ❌ Leaderboard data

### Is My Data Encrypted?

No, your backup data is stored as plain JSON in the gist. Anyone with the gist URL can read it.

**Privacy considerations**:

- The gist is **secret** (unlisted), so it won't appear in search results
- Only people with the direct URL can view it
- If you need encryption, consider using local export/import with a secure storage location

### Token Security

- Your GitHub token is like a password - keep it secret
- Store it in a password manager
- You can revoke tokens anytime at [github.com/settings/tokens](https://github.com/settings/tokens)
- If you think your token is compromised, revoke it immediately and create a new one

## Viewing Your Backup on GitHub

You can view your backup directly on GitHub:

1. Open **Backups** in Countapp
2. Tap **"Open Gist"**
3. Your backup gist opens in your browser

Or manually:

1. Go to [gist.github.com](https://gist.github.com)
2. Click your profile picture → "Your gists"
3. Find the gist named **"Countapp backup data"**
4. Click to view the JSON content

You can also:

- View the gist's revision history
- Manually edit the JSON (advanced)
- Delete the gist if you want to remove your backup

## Local Backups

If you prefer not to use GitHub, you can still use the traditional export/import features:

- **Export**: Saves counters to a local JSON file
- **Import**: Restores counters from a JSON file

These options are available in the app drawer.

## Differences: Backups vs Export/Import

| Feature           | Cloud Backup         | Local Export/Import     |
| ----------------- | -------------------- | ----------------------- |
| Storage Location  | GitHub Gist          | Your device/file system |
| Cross-device sync | ✅ Yes               | ❌ Manual file transfer |
| Automatic         | ✅ Optional on start | ❌ Manual only          |
| Internet required | ✅ Yes               | ❌ No                   |
| GitHub account    | ✅ Required          | ❌ Not required         |
| Privacy           | Secret gist          | Fully private           |

Choose the method that best fits your needs!
