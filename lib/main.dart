// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:hdmeal/screens/home.dart';
import 'package:hdmeal/screens/settings.dart';
import 'package:hdmeal/screens/settings/changeorder.dart';
import 'package:hdmeal/screens/settings/notifications.dart';
import 'package:hdmeal/screens/settings/about.dart';
import 'package:hdmeal/screens/settings/appinfo/osslicences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

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
            fillColor: Colors.black,
          )
        },
      ),
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/settings': (context) => SettingsPage(),
      '/settings/changeOrder': (context) => ChangeOrderPage(),
      '/settings/notifications': (context) => NotificationSettingsPage(),
      '/settings/appInfo': (context) => AboutPage(),
      '/settings/appInfo/OSSLicences': (context) => OSSLicencesPage(),
    },
    navigatorObservers: [
      routeObserver,
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
  ));
}
