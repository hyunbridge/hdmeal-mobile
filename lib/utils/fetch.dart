// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';

import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/extensions/date_only_compare.dart';

class FetchData {
  bool cacheUsed = false;
  String reason;

  Future<Map> fetch() async {
    try {
      ConnectivityResult connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        DateTime _now = DateTime.now();
        DateTime _cacheUpdatedTime = await Cache().getUpdatedTime();
        if (_now.isSameDate(_cacheUpdatedTime)) {
          String _cache = await Cache().read();
          if (_cache != null) {
            cacheUsed = true;
            reason = "데이터 절약을 위해";
            if (reason == null) {
              reason = "서버에 연결할 수 없어";
            }
            return json.decode(_cache);
          }
        }
      }
      final response =
          await Client().get('https://app.api.hdml.kr/api/v4/app/');
      Cache().write(response.body);
      return json.decode(response.body);
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
