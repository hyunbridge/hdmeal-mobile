// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hdmeal/utils/preferences_manager.dart';
import 'package:hdmeal/utils/theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  @override
  _ThemeSettingsState createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettingsPage> {
  ScrollController _scrollController;

  final PrefsManager _prefsManager = PrefsManager();

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
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: CustomScrollView(
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
                    vertical: 14.0, horizontal: _horizontalTitlePadding),
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
                groupValue: _prefsManager.get('theme') as String,
                onChanged: (String value) async {
                  setState(() => _prefsManager.set('theme', value));
                  themeNotifier.handleChangeTheme();
                },
              ),
              RadioListTile(
                title: const Text('항상 밝게'),
                value: 'Light',
                groupValue: _prefsManager.get('theme') as String,
                onChanged: (String value) async {
                  setState(() => _prefsManager.set('theme', value));
                  themeNotifier.handleChangeTheme();
                },
              ),
              RadioListTile(
                title: const Text('항상 어둡게'),
                value: 'Dark',
                groupValue: _prefsManager.get('theme') as String,
                onChanged: (String value) async {
                  setState(() => _prefsManager.set('theme', value));
                  themeNotifier.handleChangeTheme();
                },
              ),
              Divider(),
              SwitchListTile(
                title: const Text('다크 테마 대신 블랙 테마 사용'),
                value: _prefsManager.get('enableBlackTheme'),
                onChanged: (bool value) async {
                  setState(() => _prefsManager.set('enableBlackTheme', value));
                  themeNotifier.handleChangeTheme();
                },
              ),
              Divider(),
              ListTile(
                title: Text('기본값으로 복원'),
                onTap: () async {
                  setState(() {
                    _prefsManager.reset('theme');
                    _prefsManager.reset('enableBlackTheme');
                  });
                  themeNotifier.handleChangeTheme();
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
