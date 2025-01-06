import "package:package_info_plus/package_info_plus.dart";
import "package:pub_semver/pub_semver.dart";

Future<Version> getVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return Version.parse(packageInfo.version);
}

Future<Version> getLatestVersion() async {
  await Future.delayed(const Duration(seconds: 3));
  const latestVersion = "1.2.3";
  return Version.parse(latestVersion);
}
