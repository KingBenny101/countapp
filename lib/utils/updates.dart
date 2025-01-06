import "package:connectivity_plus/connectivity_plus.dart";
import "package:http/http.dart" as http;
import "package:package_info_plus/package_info_plus.dart";
import "package:pub_semver/pub_semver.dart";
import "package:yaml/yaml.dart";

Future<Version> getVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return Version.parse(packageInfo.version);
}

Future<Version> getLatestVersion() async {
  final errorVersion = Version.parse("0.0.0");
  const url =
      "https://raw.githubusercontent.com/KingBenny101/countapp/refs/heads/master/pubspec.yaml";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final yamlMap = loadYaml(response.body) as YamlMap;
    final latestVersion = yamlMap["version"];
    return Version.parse(latestVersion as String);
  }
  return errorVersion;
}

Future<bool> checkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.ethernet)) {
    return true;
  }
  return false;
}
