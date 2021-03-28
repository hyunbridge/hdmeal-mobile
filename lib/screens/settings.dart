// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/preferences_manager.dart';
import 'package:hdmeal/utils/theme.dart';
import 'package:hdmeal/widgets/change_grade_class.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                  "설정",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                title: Text('학년/반 변경'),
                subtitle: Text(
                    '${_prefsManager.get('userGrade')}학년 ${_prefsManager.get('userClass')}반'),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ChangeGradeClass(
                        currentGrade: _prefsManager.get('userGrade'),
                        currentClass: _prefsManager.get('userClass'),
                        onChanged: (selectedGrade, selectedClass) =>
                            setState(() {
                          _prefsManager.set('userGrade', selectedGrade);
                          _prefsManager.set('userClass', selectedClass);
                        }),
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: Text('화면 순서 변경'),
                onTap: () async {
                  Navigator.pushNamed(context, '/settings/changeOrder');
                },
              ),
              ListTile(
                title: Text('테마 설정'),
                onTap: () async {
                  Navigator.pushNamed(context, '/settings/theme');
                },
              ),
              SwitchListTile(
                title: const Text('내 학년의 학사일정만 표시'),
                value: _prefsManager.get('showMyScheduleOnly'),
                onChanged: (bool value) => setState(
                    () => _prefsManager.set('showMyScheduleOnly', value)),
              ),
              Visibility(
                child: SwitchListTile(
                  title: const Text('데이터 세이버 사용'),
                  value: _prefsManager.get('enableDataSaver'),
                  onChanged: (bool value) {
                    if (value == true) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("데이터 세이버를 켤까요?"),
                            content: new Text(
                                "데이터 세이버는 모바일 데이터 환경에서 갱신을 자제하여 데이터를 절약합니다.\n"
                                "그러나 1회 갱신에 5kb 가량의 매우 적은 데이터를 사용하므로 활성화하지 않기를 권장합니다."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text("아니요"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              new TextButton(
                                child: new Text("네"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() => _prefsManager.set(
                                      'enableDataSaver', value));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(
                          () => _prefsManager.set('enableDataSaver', value));
                    }
                  },
                ),
                visible: !kIsWeb,
              ),
              SwitchListTile(
                title: const Text('알러지 정보 표시'),
                value: _prefsManager.get('allergyInfo'),
                onChanged: (bool value) =>
                    setState(() => _prefsManager.set('allergyInfo', value)),
              ),
              Divider(),
              ListTile(
                title: Text('캐시 비우기'),
                onTap: () {
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("정말 초기화할까요?"),
                        content: new Text("모든 설정이 기본값으로 돌아가며, 복구할 수 없습니다."),
                        actions: <Widget>[
                          new TextButton(
                            child: new Text("아니요"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          new TextButton(
                            child: new Text("네"),
                            onPressed: () async {
                              setState(() => _prefsManager.resetAll());
                              themeNotifier.handleChangeTheme();
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('설정을 초기화했습니다.'),
                                duration: const Duration(seconds: 3),
                              ));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Divider(),
              Visibility(
                child: ListTile(
                  title: Text('앱 정보'),
                  onTap: () async {
                    Navigator.pushNamed(context, '/settings/about');
                  },
                ),
                visible: !kIsWeb,
              ),
              Visibility(
                child: ListTile(
                  title: Text('오픈소스 라이선스'),
                  onTap: () async {
                    Navigator.pushNamed(context, '/settings/about/OSSLicences');
                  },
                ),
                visible: kIsWeb,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
