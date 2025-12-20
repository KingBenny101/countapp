# Installation Guide

Download and install Count App on your device using the pre-built packages from the official releases page.

---

## System Requirements

| Platform | Minimum Version | Recommended | Architecture |
|----------|----------------|-------------|--------------|
| **Android** | 5.0 (API 21) | 10.0+ | ARM, ARM64, x86 |
| **Windows** | 10 | 11 | x64 |
| **Linux** | Ubuntu 20.04+ | Ubuntu 22.04+ | x64 |

!!! note
    All releases are available on the [GitHub Releases page](https://github.com/KingBenny101/countapp/releases).

---

## Android (APK)

1. Download the latest `.apk` from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. On your device, allow installation from unknown sources (Settings → Security) if required.
3. Open the downloaded file and follow the prompts to install, or transfer the APK to your device and install with a file manager.

Alternative (ADB):

```bash
adb install -r countapp-1.4.2.apk
```

## Windows (ZIP)

1. Download the Windows `.zip` file from the [Releases page](https://github.com/KingBenny101/countapp/releases) (contains the binary executable).
2. Extract the zip and run the executable (double-click or via command line). Example (PowerShell):

```powershell
Expand-Archive -Path countapp-1.4.2-windows.zip -DestinationPath .\countapp
cd .\countapp
.\countapp.exe
```

(If you prefer command-line tools on WSL or Git Bash, use `unzip` and run the executable similarly.)

## Linux (tar.gz)

1. Download the Linux `tar.gz` file from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. Extract the tarball and run the included binary. Example:

```bash
tar -xzf countapp-1.4.2-linux.tar.gz
cd countapp
./countapp
```

!!! note
    Releases provide the APK (Android), a ZIP for Windows, and a tar.gz for Linux. If you need to build locally, follow the [Development setup](development.md) guide.

---

## Verification

After installation, verify that Count App is working correctly:

**Android:**
1. Open the app from your app drawer
2. You should see the empty counter list screen
3. Try creating a test counter

**Windows/Linux:**
1. Run the executable
2. The app window should open
3. Try creating a test counter

---

## Troubleshooting

### Android: "App not installed"

**Possible causes:**
- Unknown sources not enabled
- Insufficient storage space
- Conflicting app signature

**Solutions:**
1. Enable installation from unknown sources:
   - Go to Settings → Security
   - Enable "Unknown sources" or "Install unknown apps"
2. Free up storage space (need at least 50MB)
3. Uninstall any previous versions first

### Android: "Parse error"

**Possible causes:**
- Corrupted download
- Incompatible device architecture

**Solutions:**
1. Re-download the APK file
2. Verify your device architecture matches (ARM/ARM64)
3. Check Android version meets minimum requirement (5.0+)

### Windows: "Windows protected your PC"

**This is normal for unsigned applications.**

**Solution:**
1. Click "More info"
2. Click "Run anyway"
3. The app will launch normally

### Linux: Permission denied

**Solution:**
```bash
chmod +x countapp
./countapp
```

### App won't start

**Solutions:**
1. Check system requirements are met
2. Try restarting your device
3. Reinstall the application
4. Check for error logs in the app directory

---

## Want to build from source?

If you prefer building the app yourself (e.g., to modify features), follow the [Development setup](development.md) guide which explains how to use the `dev` branch and build locally.
