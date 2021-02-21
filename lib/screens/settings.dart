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
import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/menu_notification.dart';
import 'package:hdmeal/utils/shared_preferences.dart';
import 'package:hdmeal/utils/theme.dart';
import 'package:hdmeal/widgets/change_grade_class.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Prefs _prefs;
  ScrollController _scrollController;

  final Prefs _defaultPrefs = new Prefs.defaultValue();

  final MenuNotification _notification = new MenuNotification();

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
                            '${_prefs.userGrade ?? _defaultPrefs.userGrade}학년 ${_prefs.userClass ?? _defaultPrefs.userClass}반'),
                        onTap: () async {
                          ChangeGradeClass _changeGradeClass =
                              new ChangeGradeClass.dialog(
                                  currentGrade: _prefs.userGrade ??
                                      _defaultPrefs.userGrade,
                                  currentClass: _prefs.userClass ??
                                      _defaultPrefs.userClass);
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _changeGradeClass;
                            },
                          );
                          setState(() {
                            _prefs.userGrade = _changeGradeClass.selectedGrade;
                            _prefs.userClass = _changeGradeClass.selectedClass;
                            SharedPrefs().push(_prefs);
                          });
                        },
                      ),
                      ListTile(
                        title: Text('화면 순서 변경'),
                        onTap: () async {
                          Navigator.pushNamed(context, '/settings/changeOrder');
                        },
                      ),
                      ListTile(
                        title: Text('알림 설정'),
                        onTap: () async {
                          Navigator.pushNamed(
                              context, '/settings/notifications');
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
                        value: _prefs.showMyScheduleOnly ??
                            _defaultPrefs.showMyScheduleOnly,
                        onChanged: (bool value) {
                          setState(() {
                            _prefs.showMyScheduleOnly = value;
                            SharedPrefs().push(_prefs);
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('알러지 정보 표시'),
                        value: _prefs.allergyInfo ?? _defaultPrefs.allergyInfo,
                        onChanged: (bool value) {
                          setState(() {
                            _prefs.allergyInfo = value;
                            SharedPrefs().push(_prefs);
                          });
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('캐시 비우기'),
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: new Text("캐시를 비울까요?"),
                                content: new Text(
                                    "캐시는 앱에서 알아서 관리하기 때문에 다른 문제가 없다면 굳이 비울 필요가 없습니다.\n"
                                    "캐시의 용량은 대개 0.5MB 이내로 비우더라도 용량 확보에 거의 도움이 되지 않으며, "
                                    "자주 비울 경우 같은 데이터를 반복 요청하게 되므로 네트워크 사용량이 늘어날 수 있습니다.\n"
                                    "캐시를 비우면 다음 실행 시까지 오프라인에서 앱을 이용하실 수 없게 됩니다."),
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
                                      Cache().clear();
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text('캐시를 비웠습니다.'),
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
                                      setState(() => _prefs = _defaultPrefs);
                                      await SharedPrefs().push(_prefs);
                                      themeNotifier.handleChangeTheme();
                                      _notification.unsubscribe();
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
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
