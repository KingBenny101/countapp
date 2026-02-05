# Installation Guide

Download and install Count App on your device using the pre-built packages from the official releases page.

!!! note "Downloads"
    All releases are available on the [GitHub Releases page](https://github.com/KingBenny101/countapp/releases).

---

## Android (apk)

1. Download the latest `.apk` from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. On your device, allow installation from unknown sources (Settings → Security) if required.
3. Open the downloaded file and follow the prompts to install.

**Alternative (adb):**
```bash
adb install -r countapp-1.5.7.apk
```

---

## Windows (zip)

1. Download the Windows `.zip` file from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. Extract the zip file to a folder of your choice.
3. Run `countapp.exe`.

!!! note "Windows Defender"
    Windows might prevent the app from starting because it's unsigned. Click "More info" → "Run anyway" to proceed.

---

## macOS (.app)

1. Download the macOS `.zip` file from the [Releases page](https://github.com/KingBenny101/countapp/releases).
2. Extract the zip file to get `Count App.app`.
3. Drag `Count App.app` to your Applications folder.
4. Double-click to launch.

!!! warning "Security Warning"
    On first launch, macOS may block the app. Control-click (right-click) the app icon and select "Open" from the menu, then click "Open" in the dialog box.

---

## Linux (tar.gz)

1. Download the Linux `tar.gz` file.
2. Extract the tarball:
   ```bash
   tar -xzf countapp-1.5.7-linux.tar.gz
   cd countapp
   ```
3. Run the application:
   ```bash
   chmod +x countapp  # If needed
   ./countapp
   ```

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

If you prefer building the app yourself (e.g., to modify features), follow the [Development setup](../developers/setup.md) guide which explains how to use the `dev` branch and build locally.
