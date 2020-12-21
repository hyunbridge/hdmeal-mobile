// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:async/async.dart';

import 'package:hdmeal/screens/settings/changeorder.dart';
import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                        _prefs.userGrade = value;
                        SharedPrefs().push(_prefs);
                      });
                    },
                    child: ListTile(
                      title: Text('학년'),
                      subtitle: Text("${_prefs.userGrade}학년"),
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
                        _prefs.userClass = value;
                        SharedPrefs().push(_prefs);
                      });
                    },
                    child: ListTile(
                      title: Text('반'),
                      subtitle: Text("${_prefs.userClass}반"),
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
                  ListTile(
                    title: Text('화면 순서 변경'),
                    onTap: () async {
                      Navigator.of(context).push<void>(MaterialPageRoute(
                          builder: (_) => ChangeOrderPage()
                      ));
                    },
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
                  Divider(),
                  ListTile(
                    title: Text('캐시 비우기'),
                    onTap: () async {
                      Cache().clear();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('캐시를 비웠습니다.'),
                        duration: const Duration(seconds: 3),
                      ));
                    },
                  ),
                  ListTile(
                    title: Text('설정 초기화'),
                    onTap: () async {
                      setState(() {
                        _prefs = new Prefs.defaultValue();
                        SharedPrefs().push(_prefs);
                      });
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('설정을 초기화했습니다.'),
                        duration: const Duration(seconds: 3),
                      ));
                    },
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
