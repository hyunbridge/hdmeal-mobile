// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:shared_preferences/shared_preferences.dart';

import 'package:hdmeal/models/preferences.dart';

class SharedPrefs {
  SharedPreferences _prefs;

  void push(Prefs prefs) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setInt("Grade", prefs.grade);
    await _prefs.setInt("Class", prefs.class_);
    await _prefs.setBool("AllergyInfo", prefs.allergyInfo);
  }

  Future<Prefs> pull() async {
    _prefs = await SharedPreferences.getInstance();
    int _grade = _prefs.getInt("Grade") ?? 1;
    int _class = _prefs.getInt("Class") ?? 1;
    bool _allergyInfo = _prefs.getBool("AllergyInfo") ?? true;
    return Prefs(
      _grade,
      _class,
      _allergyInfo,
    );
  }
}
