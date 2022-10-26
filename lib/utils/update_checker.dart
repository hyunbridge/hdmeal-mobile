// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionStatus {
  final String localVersion;
  final String latestVersion;

  final int localBuild;
  final int latestBuild;

  bool get isUpdateAvailable {
    if (latestBuild > localBuild) {
      return true;
    } else {
      return false;
    }
  }

  VersionStatus._({
    required this.localVersion,
    required this.latestVersion,
    required this.localBuild,
    required this.latestBuild,
  });
}

class Client extends http.BaseClient {
  final http.Client _inner;

  Client(this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (!kIsWeb) {
      request.headers['user-agent'] =
          "HDMeal-Mobile (+https://github.com/hyunbridge/hdmeal-mobile)";
    }
    return _inner.send(request);
  }
}

Future<VersionStatus> checkForUpdate() async {
  final timestamp = DateTime.now().microsecondsSinceEpoch;

  final res = await Client(http.Client()).get(Uri.parse(
      "https://gist.githubusercontent.com/hyunbridge/42d40ca9571600ef467aeb2876aaad0e/raw/hdmeal_mobile_version.json?t=$timestamp"));
  final latest = json.decode(res.body);

  final local = await PackageInfo.fromPlatform();

  return VersionStatus._(
    localVersion: local.version,
    latestVersion: latest["version"],
    localBuild: int.parse(local.buildNumber),
    latestBuild: latest["build"],
  );
}
