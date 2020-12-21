// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hdmeal/screens/home.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
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
    ),
    darkTheme: ThemeData(
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
            fillColor:  Colors.black,
          )
        },
      ),
    ),
    home: HomePage(),
    navigatorObservers: [routeObserver],
  ));
}
