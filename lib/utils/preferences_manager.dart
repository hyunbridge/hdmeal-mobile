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

import '/models/preferences.dart';

class PrefsManager {
  static final PrefsManager _prefsManager = PrefsManager._internal();
  final Prefs _default = Prefs();
  late Prefs _prefs;

  factory PrefsManager() {
    return _prefsManager;
  }

  PrefsManager._internal();

  Future<Prefs?> _read() async {
    if (kIsWeb) {
      final Web.Storage _localStorage = Web.window.localStorage;
      String? _prefsString = _localStorage["preferences"];
      if (_prefsString != null) {
        return Prefs.fromJson(json.decode(_prefsString));
      } else {
        return null;
      }
    } else {
      Native.Directory _prefsDir = await getApplicationDocumentsDirectory();
      try {
        Native.File _prefsFile =
            new Native.File("${_prefsDir.path}/preferences.json");
        String _prefsString = _prefsFile.readAsStringSync();
        return Prefs.fromJson(json.decode(_prefsString));
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
      _prefs = await _read() ?? _default;

  Prefs get prefs => _prefs;

  set prefs(Prefs newValue) {
    _prefs = newValue;
    this._write();
  }

  void set(String key, dynamic value) {
    final _prefsMap = _prefs.toJson();
    _prefsMap[key] = value;
    prefs = Prefs.fromJson(_prefsMap);
  }

  void reset(String key) {
    final _prefsMap = _prefs.toJson();
    _prefsMap[key] = _default.toJson()[key];
    prefs = Prefs.fromJson(_prefsMap);
  }

  void resetAll() {
    _prefs = _default;
    this._delete();
  }

  Map<String, dynamic> serialize() => _prefs.toJson();
}
