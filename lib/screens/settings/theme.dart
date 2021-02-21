// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/shared_preferences.dart';
import 'package:hdmeal/utils/theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  @override
  _ThemeSettingsState createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettingsPage> {
  Prefs _prefs;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _prefs = await SharedPrefs().pull();
        return true;
      });

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    ThemeData _themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: _themeData.primaryColor,
      appBar: AppBar(
        title: Text(
          "테마 설정",
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
                  RadioListTile(
                    title: const Text('시스템 설정 따르기'),
                    value: 'System',
                    groupValue: _prefs.theme,
                    onChanged: (String value) async {
                      setState(() => _prefs.theme = value);
                      await SharedPrefs().push(_prefs);
                      themeNotifier.handleChangeTheme();
                    },
                  ),
                  RadioListTile(
                    title: const Text('항상 밝게'),
                    value: 'Light',
                    groupValue: _prefs.theme,
                    onChanged: (String value) async {
                      setState(() => _prefs.theme = value);
                      await SharedPrefs().push(_prefs);
                      themeNotifier.handleChangeTheme();
                    },
                  ),
                  RadioListTile(
                    title: const Text('항상 어둡게'),
                    value: 'Dark',
                    groupValue: _prefs.theme,
                    onChanged: (String value) async {
                      setState(() => _prefs.theme = value);
                      await SharedPrefs().push(_prefs);
                      themeNotifier.handleChangeTheme();
                    },
                  ),
                  Divider(),
                  SwitchListTile(
                    title: const Text('다크 테마 대신 블랙 테마 사용'),
                    value: _prefs.enableBlackTheme,
                    onChanged: (bool value) async {
                      setState(() => _prefs.enableBlackTheme = value);
                      await SharedPrefs().push(_prefs);
                      themeNotifier.handleChangeTheme();
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('기본값으로 복원'),
                    onTap: () async {
                      setState(() {
                        _prefs.theme = Prefs.defaultValue().theme;
                        _prefs.enableBlackTheme =
                            Prefs.defaultValue().enableBlackTheme;
                      });
                      await SharedPrefs().push(_prefs);
                      themeNotifier.handleChangeTheme();
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
