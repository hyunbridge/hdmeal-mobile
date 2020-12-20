// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

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
    ),
    darkTheme: ThemeData(
      fontFamily: "SpoqaHanSansNeo",
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      primarySwatch: Colors.grey,
      accentColor: Colors.grey[500],
      toggleableActiveColor: Colors.grey[500],
      // 다크 테마에서는 primarySwatch가 먹지 않음
    ),
    home: Navigator(
      onGenerateRoute: (settings) {
        return createHomeRoute();
      },
    ),
    navigatorObservers: [routeObserver],
  ));
}
