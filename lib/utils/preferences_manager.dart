// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:convert';
import 'dart:io' as Native;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as Web;

import 'package:hdmeal/models/preferences.dart';

class PrefsManager {
  static final PrefsManager _prefsManager = PrefsManager._internal();
  final Map<String, dynamic> _default = Prefs.defaultValue().toJson();
  Prefs _prefs;

  factory PrefsManager() {
    return _prefsManager;
  }

  PrefsManager._internal();

  Future<Map<String, dynamic>> _read() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      try {
        String _prefsString = _localStorage["preferences"];
        return json.decode(_prefsString);
      } catch (_) {
        return null;
      }
    } else {
      Native.Directory _prefsDir = await getApplicationDocumentsDirectory();
      try {
        Native.File _prefsFile =
            new Native.File("${_prefsDir.path}/preferences.json");
        String _prefsString = _prefsFile.readAsStringSync();
        return json.decode(_prefsString);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _write() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      _localStorage["preferences"] = json.encode(_prefs.toJson());
    } else {
      Native.Directory _prefsDir = await getApplicationDocumentsDirectory();
      Native.File _prefsFile =
          new Native.File("${_prefsDir.path}/preferences.json");
      await _prefsFile.writeAsString(json.encode(_prefs.toJson()));
    }
  }

  Future<void> _delete() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      _localStorage.remove("preferences");
    } else {
      Native.Directory _prefsDir = await getApplicationDocumentsDirectory();
      try {
        Native.File _prefsFile =
            new Native.File("${_prefsDir.path}/preferences.json");
        await _prefsFile.delete();
      } catch (_) {
        //pass
      }
    }
  }

  Future<void> init() async =>
      _prefs = Prefs.fromJson(await _read() ?? _default);

  dynamic get(String key) {
    final _prefsMap = _prefs.toJson();
    return _prefsMap[key] ?? _default[key];
  }

  void set(String key, dynamic value) {
    final _prefsMap = _prefs.toJson();
    _prefsMap[key] = value;
    _prefs = Prefs.fromJson(_prefsMap);
    this._write();
  }

  void reset(String key) => this.set(key, _default[key]);

  void resetAll() {
    _prefs = Prefs.fromJson(_default);
    this._delete();
  }

  Map<String, dynamic> serialize() => _prefs.toJson();
}
