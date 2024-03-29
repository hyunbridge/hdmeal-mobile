// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import '/screens/home.dart';
import '/screens/settings.dart';
import '/screens/settings/changeorder.dart';
import '/screens/settings/keyword_highlight.dart';
import '/screens/settings/theme.dart';
import '/screens/settings/about.dart';
import '/screens/settings/about/licences.dart';
import '/utils/preferences_manager.dart';
import '/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  await PrefsManager().init();

  final ThemeData theme = ThemeNotifier().determineTheme();

  usePathUrlStrategy();

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(theme),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      themeNotifier.handleChangeTheme();
    };

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      debugPrint('SystemChannels> $msg');
      if (msg == AppLifecycleState.resumed.toString()) {
        themeNotifier.setSystemUIOverlayStyle(themeNotifier.getTheme());
      }
      return "";
    });

    return MaterialApp(
      title: "흥덕고 급식",
      theme: themeNotifier.getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/settings': (context) => SettingsPage(),
        '/settings/change_order': (context) => ChangeOrderPage(),
        '/settings/keyword_highlight': (context) => KeywordHighlightPage(),
        '/settings/theme': (context) => ThemeSettingsPage(),
        '/settings/about': (context) => AboutPage(),
        '/settings/about/licences': (context) => LicencesPage(),
      },
      navigatorObservers: [
        routeObserver,
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      supportedLocales: [
        const Locale('ko'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
    );
  }
}
