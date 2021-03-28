// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:io' as Native;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as Web;

class Cache {
  Future<String> read() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      return _localStorage["cache"];
    } else {
      Native.Directory _cacheDir = await getTemporaryDirectory();
      try {
        return Native.File("${_cacheDir.path}/cache.json").readAsStringSync();
      } on Native.FileSystemException {
        return null;
      }
    }
  }

  Future<DateTime> getUpdatedTime() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      try {
        final int _timestamp = _localStorage["cache_last_updated"] as int;
        return DateTime.fromMicrosecondsSinceEpoch(_timestamp);
      } catch (_) {
        return null;
      }
    } else {
      Native.Directory _cacheDir = await getTemporaryDirectory();
      try {
        Native.FileStat stat =
            Native.FileStat.statSync("${_cacheDir.path}/cache.json");
        return stat.modified;
      } on Native.FileSystemException {
        return null;
      }
    }
  }

  void write(String data) async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      _localStorage["cache"] = data;
      _localStorage["cache_last_updated"] =
          "${DateTime.now().millisecondsSinceEpoch}";
    } else {
      Native.Directory _cacheDir = await getTemporaryDirectory();
      Native.File _cache = new Native.File("${_cacheDir.path}/cache.json");
      _cache.writeAsString(data);
    }
  }

  void clear() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      _localStorage.remove("cache");
      _localStorage.remove("cache_last_updated");
    } else {
      Native.Directory _cacheDir = await getTemporaryDirectory();
      Native.File _cache = new Native.File("${_cacheDir.path}/cache.json");
      await _cache.delete();
    }
  }
}
