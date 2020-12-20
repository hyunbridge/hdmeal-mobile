// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:async/async.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/shared_preferences.dart';

Route createSettingsRoute() {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => _SettingsPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        fillColor: Colors.transparent,
        transitionType: SharedAxisTransitionType.scaled,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}

class _SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  String _appVersion;
  Prefs _prefs;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _prefs = await SharedPrefs().pull();
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        _appVersion = packageInfo.version;
        return true;
      });

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "설정",
        ),
      ),
      body: FutureBuilder(
          future: asyncMethod(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center));
            }

            if (snapshot.hasData && snapshot.data) {
              return ListView(
                children: [
                  PopupMenuButton<int>(
                    onSelected: (int value) {
                      setState(() {
                        _prefs.grade = value;
                        SharedPrefs().push(_prefs);
                      });
                    },
                    child: ListTile(
                      title: Text('학년'),
                      subtitle: Text("${_prefs.grade}학년"),
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('1학년'),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text('2학년'),
                      ),
                      const PopupMenuItem<int>(
                        value: 3,
                        child: Text('3학년'),
                      ),
                    ],
                  ),
                  PopupMenuButton<int>(
                    onSelected: (int value) {
                      setState(() {
                        _prefs.class_ = value;
                        SharedPrefs().push(_prefs);
                      });
                    },
                    child: ListTile(
                      title: Text('반'),
                      subtitle: Text("${_prefs.class_}반"),
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('1반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text('2반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 3,
                        child: Text('3반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 4,
                        child: Text('4반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 5,
                        child: Text('5반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 6,
                        child: Text('6반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 7,
                        child: Text('7반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 8,
                        child: Text('8반'),
                      ),
                      const PopupMenuItem<int>(
                        value: 9,
                        child: Text('9반'),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('알러지 정보 표시'),
                    value: _prefs.allergyInfo,
                    onChanged: (bool value) {
                      setState(() {
                        _prefs.allergyInfo = value;
                        SharedPrefs().push(_prefs);
                      });
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('웹 앱 열기'),
                    subtitle: Text("app.hdml.kr"),
                    onTap: () async {
                      launch("https://app.hdml.kr/");
                    },
                  ),
                  ListTile(
                    title: Text('개발자에게 문의하기'),
                    subtitle: Text("hekn2y4j@duck.com"),
                    onTap: () async {
                      launch("mailto:hekn2y4j@duck.com");
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('앱 버전'),
                    subtitle: Text("$_appVersion"),
                  ),
                  ListTile(
                    title: Text('저작권'),
                    subtitle: Text("Copyright (c) 2020 Hyungyo Seo."),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
