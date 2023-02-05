// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:hdmeal/utils/preferences_manager.dart';

final lightTheme = ThemeData(
  fontFamily: "SpoqaHanSansNeo",
  brightness: Brightness.light,
  primaryColor: Colors.white,
  primarySwatch: Colors.grey,
);

final darkTheme = ThemeData(
  fontFamily: "SpoqaHanSansNeo",
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  primarySwatch: Colors.grey,
  accentColor: Colors.grey[500],
  toggleableActiveColor: Colors.grey[500],
);

final blackTheme = ThemeData(
  fontFamily: "SpoqaHanSansNeo",
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  primarySwatch: Colors.grey,
  accentColor: Colors.grey[500],
  toggleableActiveColor: Colors.grey[500],
);

class ThemeNotifier with ChangeNotifier {
  ThemeData? _themeData;

  ThemeNotifier([this._themeData]);

  getTheme() => _themeData;

  void setTheme(ThemeData themeData) async {
    _themeData = themeData;
    setSystemUIOverlayStyle(themeData);
    notifyListeners();
  }

  void setSystemUIOverlayStyle(ThemeData themeData) async {
    switch (themeData.brightness) {
      case Brightness.light:
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: themeData.primaryColor.withOpacity(0.95),
          systemNavigationBarIconBrightness: Brightness.dark,
        ));
        break;
      case Brightness.dark:
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: themeData.primaryColor.withOpacity(0.95),
          systemNavigationBarIconBrightness: Brightness.light,
        ));
        break;
    }
  }

  void handleChangeTheme() {
    this.setTheme(determineTheme());
  }

  ThemeData determineTheme() {
    final _prefsManager = PrefsManager();
    final String _theme = _prefsManager.get('theme');
    final bool _enableBlackTheme = _prefsManager.get('enableBlackTheme');
    switch (_theme) {
      case 'System':
        if (SchedulerBinding.instance.window.platformBrightness ==
            Brightness.dark) {
          if (_enableBlackTheme == true) {
            return blackTheme;
          } else {
            return darkTheme;
          }
        } else {
          return lightTheme;
        }
      case 'Dark':
        if (_enableBlackTheme == true) {
          return blackTheme;
        } else {
          return darkTheme;
        }
    }
    return lightTheme;
  }
}
