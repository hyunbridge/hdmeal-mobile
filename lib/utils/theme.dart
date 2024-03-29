// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '/utils/preferences_manager.dart';

const fontFamily = "SUIT";

final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.blue,
);

final darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
);

final blackTheme = darkTheme.copyWith(
  scaffoldBackgroundColor: Colors.black,
  colorScheme: darkTheme.colorScheme.copyWith(
    background: Colors.black,
    surface: Colors.black,
  ),
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
    // Set theme-color meta tag as background color in web
    // https://github.com/flutter/engine/blob/main/lib/web_ui/lib/src/engine/platform_dispatcher.dart
    // TODO: Find a better way.
    if (kIsWeb) {
      SystemChrome.setApplicationSwitcherDescription(
          ApplicationSwitcherDescription(
              label: "흥덕고 급식",
              primaryColor: themeData.colorScheme.background.value));
    }

    switch (themeData.brightness) {
      case Brightness.light:
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor:
              themeData.colorScheme.background.withOpacity(0.95),
          systemNavigationBarIconBrightness: Brightness.dark,
        ));
        break;
      case Brightness.dark:
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor:
              themeData.colorScheme.background.withOpacity(0.95),
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
    final _prefs = _prefsManager.prefs;
    final String _theme = _prefs.theme;
    final bool _enableBlackTheme = _prefs.enableBlackTheme;
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
