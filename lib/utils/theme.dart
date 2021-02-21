// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/shared_preferences.dart';

final lightTheme = ThemeData(
  fontFamily: "SpoqaHanSansNeo",
  brightness: Brightness.light,
  primaryColor: Colors.white,
  primarySwatch: Colors.grey,
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
      )
    },
  ),
);

final darkTheme = ThemeData(
  fontFamily: "SpoqaHanSansNeo",
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  primarySwatch: Colors.grey,
  accentColor: Colors.grey[500],
  toggleableActiveColor: Colors.grey[500],
  // 다크 테마에서는 primarySwatch가 먹지 않음
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.grey[900],
      )
    },
  ),
);

final blackTheme = ThemeData(
  fontFamily: "SpoqaHanSansNeo",
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  primarySwatch: Colors.grey,
  accentColor: Colors.grey[500],
  toggleableActiveColor: Colors.grey[500],
  // 다크 테마에서는 primarySwatch가 먹지 않음
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.black,
      )
    },
  ),
);

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier([this._themeData]);

  getTheme() => _themeData;

  void setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }

  void handleChangeTheme() async {
    this.setTheme(await determineTheme());
  }

  Future<ThemeData> determineTheme() async {
    final Prefs prefs = await SharedPrefs().pull();
    switch (prefs.theme) {
      case 'System':
        if (SchedulerBinding.instance.window.platformBrightness ==
            Brightness.dark) {
          if (prefs.enableBlackTheme == true) {
            return blackTheme;
          } else {
            return darkTheme;
          }
        } else {
          return lightTheme;
        }
        break;
      case 'Dark':
        if (prefs.enableBlackTheme == true) {
          return blackTheme;
        } else {
          return darkTheme;
        }
        break;
    }
    return lightTheme;
  }
}
