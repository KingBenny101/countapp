import "package:permission_handler/permission_handler.dart";

Future<bool> checkAndRequestStoragePermission() async {
  final PermissionStatus status = await Permission.manageExternalStorage.status;

  if (status.isGranted) {
    return true;
  } else {
    final PermissionStatus newStatus = await Permission.manageExternalStorage.request();

    return newStatus.isGranted;
  }
}
