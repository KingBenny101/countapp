# Install — Get the app

Download the ready-to-run installers and packages from the official Releases page and install on your device.

## Releases

Visit the Count App Releases page:

- https://github.com/KingBenny101/countapp/releases

Choose the asset for your platform and follow the simple steps below.

### Android (APK)

1. Download the latest `.apk` from the Releases page.
2. On your device, allow installation from unknown sources (Settings → Security) if required.
3. Open the downloaded file and follow the prompts to install, or transfer the APK to your device and install with a file manager.

Alternative (ADB):

```bash
adb install -r path/to/countapp.apk
```

### Windows (binary / installer)

1. Download the Windows binary (`.exe`) or `.zip` from Releases.
2. If a `.exe` installer is provided: run it and follow the prompts.
3. If a `.zip` is provided: extract and run the included executable.

### Linux (binary)

1. Download the Linux binary (usually an AppImage or tarball) from Releases.
2. Make it executable and run (example for AppImage):

```bash
chmod +x CountApp-*.AppImage
./CountApp-*.AppImage
```

3. If a tarball is provided, extract and run the included binary.

> Note: Releases provide the APK and platform binaries for Android, Windows, and Linux. If you need to build locally, follow the [Development setup](development.md) guide.

---

### Want to build from source?

If you prefer building the app yourself (e.g., to modify features), follow the [Development setup](development.md) guide which explains how to use the `dev` branch and build locally.
