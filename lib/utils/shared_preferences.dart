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

class SharedPrefs {
  Prefs defaultValues = new Prefs.defaultValue();

  void push(Prefs prefs) async {
    Directory _prefsDir = await getApplicationDocumentsDirectory();
    File _prefsFile = new File("${_prefsDir.path}/preferences.json");
    _prefsFile.writeAsString(json.encode(prefs.toJson()));
  }

  Future<Prefs> pull() async {
    Directory _prefsDir = await getApplicationDocumentsDirectory();
    try {
      File _prefsFile = new File("${_prefsDir.path}/preferences.json");
      String _prefsString = _prefsFile.readAsStringSync();
      return new Prefs.fromJson(json.decode(_prefsString));
    } catch (_) {
      return defaultValues;
    }
  }
}
