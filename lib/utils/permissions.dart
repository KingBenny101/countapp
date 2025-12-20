import "dart:io" show Platform;
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/services.dart" show MissingPluginException;
import "package:permission_handler/permission_handler.dart";

/// On platforms where `permission_handler` doesn't implement storage permissions
/// (for example Linux desktop), we assume the permission is not required and
/// allow exports to proceed. Android requires explicit storage permission.
Future<bool> checkAndRequestStoragePermission() async {
  // Web does not require host storage permissions
  if (kIsWeb) return true;

  // Android requires manageExternalStorage
  if (Platform.isAndroid) {
    try {
      final PermissionStatus status =
          await Permission.manageExternalStorage.status;

      if (status.isGranted) {
        return true;
      } else {
        final PermissionStatus newStatus =
            await Permission.manageExternalStorage.request();
        return newStatus.isGranted;
      }
    } on MissingPluginException {
      // Plugin not implemented on this platform - treat as allowed
      return true;
    } catch (_) {
      return false;
    }
  }

  // For other desktop/mobile platforms, no special permission is needed
  return true;
}
