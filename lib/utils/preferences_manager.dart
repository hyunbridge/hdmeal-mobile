// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
    Directory _prefsDir = await getApplicationDocumentsDirectory();
    try {
      File _prefsFile = new File("${_prefsDir.path}/preferences.json");
      String _prefsString = _prefsFile.readAsStringSync();
      return json.decode(_prefsString);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write() async {
    Directory _prefsDir = await getApplicationDocumentsDirectory();
    File _prefsFile = new File("${_prefsDir.path}/preferences.json");
    await _prefsFile.writeAsString(json.encode(_prefs.toJson()));
  }

  Future<void> _delete() async {
    Directory _prefsDir = await getApplicationDocumentsDirectory();
    try {
      File _prefsFile = new File("${_prefsDir.path}/preferences.json");
      await _prefsFile.delete();
    } catch (_) {
      //pass
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
