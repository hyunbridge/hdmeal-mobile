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
  Prefs defaultValues = new Prefs.defaultValue();

  void push(Prefs prefs) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setInt("Grade", prefs.userGrade);
    await _prefs.setInt("Class", prefs.userClass);
    await _prefs.setBool("AllergyInfo", prefs.allergyInfo);
    await _prefs.setStringList("SectionOrder", prefs.sectionOrder);
  }

  Future<Prefs> pull() async {
    _prefs = await SharedPreferences.getInstance();
    print(defaultValues.userGrade);
    int _grade = _prefs.getInt("Grade") ?? defaultValues.userGrade;
    int _class = _prefs.getInt("Class") ?? defaultValues.userGrade;
    bool _allergyInfo = _prefs.getBool("AllergyInfo") ?? defaultValues.allergyInfo;
    List<String> _sectionOrder =
        _prefs.getStringList("SectionOrder") ?? defaultValues.sectionOrder;
    return Prefs(
      _grade,
      _class,
      _allergyInfo,
      _sectionOrder,
    );
  }
}
