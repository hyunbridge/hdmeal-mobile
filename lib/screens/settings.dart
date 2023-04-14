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
  late ScrollController _scrollController;

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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              SliverAppBar.large(
                floating: false,
                pinned: true,
                snap: false,
                stretch: true,
                flexibleSpace: new FlexibleSpaceBar(
                  titlePadding: EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: _horizontalTitlePadding),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "설정",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ListTile(
                      title: Text('학년/반 변경'),
                      subtitle: Text(
                          '${_prefsManager.prefs.userGrade}학년 ${_prefsManager.prefs.userClass}반'),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ChangeGradeClass(
                              currentGrade: _prefsManager.prefs.userGrade,
                              currentClass: _prefsManager.prefs.userClass,
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
                        Navigator.pushNamed(context, '/settings/change_order');
                      },
                    ),
                    ListTile(
                      title: Text('테마 설정'),
                      onTap: () async {
                        Navigator.pushNamed(context, '/settings/theme');
                      },
                    ),
                    ListTile(
                      title: Text('키워드 강조'),
                      onTap: () async {
                        Navigator.pushNamed(
                            context, '/settings/keyword_highlight');
                      },
                    ),
                    SwitchListTile(
                      title: const Text('내 학년의 학사일정만 표시'),
                      value: _prefsManager.prefs.showMyScheduleOnly,
                      onChanged: (bool value) => setState(
                          () => _prefsManager.set('showMyScheduleOnly', value)),
                    ),
                    SwitchListTile(
                      title: const Text('알러지 정보 표시'),
                      value: _prefsManager.prefs.allergyInfo,
                      onChanged: (bool value) => setState(
                          () => _prefsManager.set('allergyInfo', value)),
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
                              content:
                                  new Text("모든 설정이 기본값으로 돌아가며, 복구할 수 없습니다."),
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
                    ListTile(
                      title: Text('앱 정보'),
                      onTap: () async {
                        Navigator.pushNamed(context, '/settings/about');
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
