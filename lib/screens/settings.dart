// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/shared_preferences.dart';
import 'package:hdmeal/widgets/change_grade_class.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("설정"),
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
                  ListTile(
                    title: Text('학년/반 변경'),
                    subtitle:
                        Text('${_prefs.userGrade}학년 ${_prefs.userClass}반'),
                    onTap: () async {
                      ChangeGradeClass _changeGradeClass =
                          new ChangeGradeClass.dialog(
                              currentGrade: _prefs.userGrade,
                              currentClass: _prefs.userClass);
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
                              new FlatButton(
                                child: new Text("아니요"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              new FlatButton(
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
                            content: new Text("모든 설정이 기본값으로 돌아가며, 복구할 수 없습니다."),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text("아니요"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              new FlatButton(
                                child: new Text("네"),
                                onPressed: () {
                                  setState(() {
                                    _prefs = new Prefs.defaultValue();
                                    SharedPrefs().push(_prefs);
                                  });
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
                      Navigator.pushNamed(context, '/settings/appInfo');
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
