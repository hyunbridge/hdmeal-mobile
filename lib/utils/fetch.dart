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

import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/extensions/date_only_compare.dart';

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

class FetchData {
  String? reason;
  Future<Map?> fetch() async {
    try {
      DateTime _now = DateTime.now();
      DateTime _cacheUpdatedTime = await Cache().getUpdatedTime();
      if (_now.isSameDate(_cacheUpdatedTime)) {
        String? _cache = await Cache().read();
        if (_cache != null) {
          return json.decode(_cache);
        }
      }
      final response = await Client(http.Client())
          .get(Uri.parse("https://hdmeal-api.hgseo.net/app/v4/"));
      Cache().write(response.body);
      return json.decode(response.body);
    } catch (_) {
      String? _cache = await Cache().read();
      if (_cache != null) {
        reason = "서버에 연결할 수 없어";
        return json.decode(_cache);
      } else {
        return null;
      }
    }
  }

  Future<Map?> fetchFromCache() async {
    String? _cache = await Cache().read();
    if (_cache != null) {
      return json.decode(_cache);
    } else {
      return null;
    }
  }
}
