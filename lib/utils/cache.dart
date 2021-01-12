// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Cache {
  Future<String> read() async {
    Directory _cacheDir = await getTemporaryDirectory();
    try {
      return File("${_cacheDir.path}/cache.json").readAsStringSync();
    } on FileSystemException {
      return null;
    }
  }

  Future<DateTime> getUpdatedTime() async {
    Directory _cacheDir = await getTemporaryDirectory();
    try {
      FileStat stat = FileStat.statSync("${_cacheDir.path}/cache.json");
      return stat.modified;
    } on FileSystemException {
      return null;
    }
  }

  void write(String data) async {
    Directory _cacheDir = await getTemporaryDirectory();
    File _cache = new File("${_cacheDir.path}/cache.json");
    _cache.writeAsString(data);
  }

  void clear() async {
    Directory _cacheDir = await getTemporaryDirectory();
    File _cache = new File("${_cacheDir.path}/cache.json");
    await _cache.delete();
  }
}
