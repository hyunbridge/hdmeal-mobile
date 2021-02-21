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
  ScrollController _scrollController;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _prefs = await SharedPrefs().pull();
        return true;
      });

  double get _horizontalTitlePadding {
    const kBasePadding = 16.0;
    const kMultiplier = 2.0;

    if (_scrollController.hasClients) {
      if (_scrollController.offset < (150 / 2)) {
        // In case 50%-100% of the expanded height is viewed
        return kBasePadding;
      }

      if (_scrollController.offset > (150 - kToolbarHeight)) {
        // In case 0% of the expanded height is viewed
        return (150 / 2 - kToolbarHeight) * kMultiplier + kBasePadding;
      }

      // In case 0%-50% of the expanded height is viewed
      return (_scrollController.offset - (150 / 2)) * kMultiplier +
          kBasePadding;
    }

    return kBasePadding;
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: false,
                    pinned: true,
                    snap: false,
                    stretch: true,
                    flexibleSpace: new FlexibleSpaceBar(
                        titlePadding: EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: _horizontalTitlePadding),
                        title: Text(
                          "테마 설정",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
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
                    ]),
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
