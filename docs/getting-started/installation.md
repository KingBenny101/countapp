# Install — Get the app

Download the ready-to-run installers and packages from the official Releases page and install on your device.

## Releases

Visit the Count App Releases page: [Count App Releases](https://github.com/KingBenny101/countapp/releases)

Choose the asset for your platform and follow the simple steps below.

**Current release assets (example):**

- Linux: `countapp-1.4.2-linux.tar.gz` — 15.9 MB — SHA256: `7a45d927d7746702cb17b1fa8cccb8b80c9465c615549b7b437ca991ada0328d` (uploaded 4 days ago)
- Windows: `countapp-1.4.2-windows.zip` — 12.1 MB — SHA256: `e8cdf62344adf6f55ad3b77e12131e25d77d563256db8e88555db6f39f3db305` (uploaded 4 days ago)
- Android: `countapp-1.4.2.apk` — 51.7 MB — SHA256: `4dbb6edb1cf385c6ef0752885577b14c4c3b05e8a4e1731ea04d09bb5d003f9e` (uploaded 4 days ago)

**Verify the checksum** (recommended):

- Linux / macOS:

```bash
sha256sum <filename>
# or
shasum -a 256 <filename>
```

- Windows (PowerShell):

```powershell
Get-FileHash <filename> -Algorithm SHA256
```

Compare the computed digest to the SHA256 value listed above to ensure the download is intact and authentic.

(Always check the Releases page for the latest filenames and digests if a newer release is available.)

### Android (APK)

1. Download the latest `.apk` from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. On your device, allow installation from unknown sources (Settings → Security) if required.
3. Open the downloaded file and follow the prompts to install, or transfer the APK to your device and install with a file manager.

Alternative (ADB):

```bash
adb install -r path/to/countapp.apk
```

### Windows (ZIP)

1. Download the Windows `.zip` file from the [Releases page](https://github.com/KingBenny101/countapp/releases) (contains the binary executable).
2. Extract the zip and run the executable (double-click or via command line). Example (PowerShell):

```powershell
Expand-Archive -Path CountApp-*.zip -DestinationPath .\countapp
cd .\countapp
.\CountApp.exe
```

(If you prefer command-line tools on WSL or Git Bash, use `unzip` and run the executable similarly.)

### Linux (tar.gz)

1. Download the Linux `tar.gz` file from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. Extract the tarball and run the included binary. Example:

```bash
tar -xzf CountApp-*.tar.gz
cd countapp
./countapp
```

> Note: Releases provide the APK (Android), a ZIP for Windows, and a tar.gz for Linux. If you need to build locally, follow the [Development setup](development.md) guide.

---

### Want to build from source?

If you prefer building the app yourself (e.g., to modify features), follow the [Development setup](development.md) guide which explains how to use the `dev` branch and build locally.
