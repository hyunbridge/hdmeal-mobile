// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:hdmeal/utils/cache.dart';

class FetchData {
  bool cacheUsed = false;

  Future<Map> fetch() async {
      try {
        final response =
        await Client().get('https://app.api.hdml.kr/api/v3/app/');
        Cache().write(response.body);
        return json.decode(response.body);
      } catch (_) {
        String _cache = await Cache().read();
        cacheUsed = true;
        if (_cache != null) {
          return json.decode(_cache);
        } else {
          return null;
        }
      }
  }
}
