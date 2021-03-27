// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:async';
import 'dart:convert';

import 'package:brotli/brotli.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/preferences_manager.dart';
import 'package:hdmeal/extensions/date_only_compare.dart';

class Client extends http.BaseClient {
  final http.Client _inner;

  Client(this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] =
        "HDMeal-Mobile (+https://github.com/hyunbridge/hdmeal-mobile)";
    return _inner.send(request);
  }
}

class FetchData {
  bool cacheUsed = false;
  String reason;
  final PrefsManager _prefsManager = PrefsManager();

  Future<Map> fetch() async {
    try {
      ConnectivityResult connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile &&
          _prefsManager.get('enableDataSaver') == true) {
        DateTime _now = DateTime.now();
        DateTime _cacheUpdatedTime = await Cache().getUpdatedTime();
        if (_now.isSameDate(_cacheUpdatedTime)) {
          String _cache = await Cache().read();
          if (_cache != null) {
            cacheUsed = true;
            reason = "데이터 세이버가 켜져 있어";
            if (reason == null) {
              reason = "서버에 연결할 수 없어";
            }
            return json.decode(_cache);
          }
        }
      }
      final response = await Client(http.Client())
          .get(Uri.parse("https://api.hdml.kr/api/v4/app/br/"));
      final decompressed =
          brotli.decodeToString(response.bodyBytes, encoding: utf8);
      Cache().write(decompressed);
      return json.decode(decompressed);
    } catch (_) {
      String _cache = await Cache().read();
      if (_cache != null) {
        cacheUsed = true;
        reason = "서버에 연결할 수 없어";
        return json.decode(_cache);
      } else {
        return null;
      }
    }
  }

  Future<Map> fetchFromCache() async {
    String _cache = await Cache().read();
    if (_cache != null) {
      return json.decode(_cache);
    } else {
      return null;
    }
  }
}
