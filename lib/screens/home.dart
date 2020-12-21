// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'package:share/share.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/screens/settings.dart';
import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/shared_preferences.dart';
import 'package:hdmeal/utils/fetch.dart';
import 'package:hdmeal/extensions/date_only_compare.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Prefs _prefs;

  final AsyncMemoizer _fetchDataMemoizer = AsyncMemoizer();
  final AsyncMemoizer _timeErrorSnackBarMemoizer = AsyncMemoizer();

  void asyncMethod() async {
    _prefs = await SharedPrefs().pull();
  }

  Future fetchData() => _fetchDataMemoizer.runOnce(() async {
        FetchData _fetch = new FetchData();
        Map _data = await _fetch.fetch();
        if (_data == null) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("서버에 연결할 수 없음"),
                content: new Text("기기의 인터넷 연결 상태를 확인해 주세요."),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("앱 종료"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (_fetch.cacheUsed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${_fetch.reason} 기기에 저장된 캐시를 이용합니다.'),
            duration: const Duration(seconds: 3),
          ));
        }
        return _data;
      });

  makePages(data) {
    List<Widget> _pages = [];
    int _todayIndex;
    PageController _controller;
    const List _weekday = ["", "월", "화", "수", "목", "금", "토", "일"];
    const List _allergyString = [
      "",
      "난류",
      "우유",
      "메밀",
      "땅콩",
      "대두",
      "밀",
      "고등어",
      "게",
      "새우",
      "돼지고기",
      "복숭아",
      "토마토",
      "아황산류",
      "호두",
      "닭고기",
      "쇠고기",
      "오징어",
      "조개류"
    ];
    try {
      data.forEach((date, data) {
        // 날짜 처리
        bool isToday = false;
        DateTime _now = DateTime.now();
        DateTime _parsedDate = DateTime.parse(date);
        if (_now.isSameDate(_parsedDate)) {
          _todayIndex = _pages.length;
          isToday = true;
        }
        String _title =
            "${_parsedDate.month}월 ${_parsedDate.day}일(${_weekday[_parsedDate.weekday]})";
        // 식단 리스트 작성
        List _menuList = [];
        List _menuStringList = [];
        List _menu = data["Meal"][0] ??
            [
              ["식단정보가 없습니다.", []]
            ];
        _menu.forEach((element) {
          _menuStringList.add(element[0]);
          if (_prefs.allergyInfo) {
            String _allergyInfo = "";
            element[1].forEach((element) =>
                _allergyInfo = "$_allergyInfo, ${_allergyString[element]}");
            _allergyInfo = _allergyInfo.replaceFirst(", ", "");
            if (!(_allergyInfo == "")) {
              _menuList.add(ListTile(
                title: Text(element[0]),
                subtitle: Text(
                  _allergyInfo,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                visualDensity: VisualDensity(vertical: -4),
              ));
            } else {
              _menuList.add(ListTile(
                title: Text(element[0]),
                visualDensity: VisualDensity(vertical: -4),
              ));
            }
          } else {
            _menuList.add(ListTile(
              title: Text(element[0]),
              visualDensity: VisualDensity(vertical: -4),
            ));
          }
        });
        // 시간표 리스트 작성
        List _timetableList = [];
        List _timetable =
            data["Timetable"]["${_prefs.userGrade}"]["${_prefs.userClass}"];
        if (_timetable.length == 0) _timetable = ["시간표 정보가 없습니다."];
        _timetable.forEach((element) {
          if (element.contains("⭐")) {
            _timetableList.add(ListTile(
              title: Text(
                element.replaceAll("⭐", ""),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              visualDensity: VisualDensity(vertical: -4),
            ));
          } else {
            _timetableList.add(ListTile(
              title: Text(element),
              visualDensity: VisualDensity(vertical: -4),
            ));
          }
        });
        // 학사일정 리스트 작성
        List _scheduleList = [];
        List _schedule = data["Schedule"] ?? ["학사일정이 없습니다."];
        _schedule.forEach((element) => _scheduleList.add(ListTile(
              title: Text(element),
              visualDensity: VisualDensity(vertical: -4),
            )));
        // 섹션 내부 작성
        List<Widget> _widgets = [];
        Map _sections = {
          "Meal": [
            ListTile(
              title: Text(
                "급식",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share("<${_parsedDate.month}월 ${_parsedDate.day}일(${_weekday[_parsedDate.weekday]})>\n${_menuStringList.join(",\n")}");
                  }),
            ),
            ..._menuList,
          ],
          "Timetable": [
            ListTile(
              title: Text(
                "${_prefs.userGrade}학년 ${_prefs.userClass}반 시간표",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._timetableList,
          ],
          "Schedule": [
            ListTile(
              title: Text(
                "학사일정",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._scheduleList
          ]
        };
        _prefs.sectionOrder.forEach((element) {
          _sections[element].forEach((element) => _widgets.add(element));
          _widgets.add(Divider());
        });
        _widgets.removeLast();
        _pages.add(
          CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              SliverAppBar(
                  expandedHeight: 150.0,
                  floating: false,
                  pinned: true,
                  snap: false,
                  stretch: true,
                  flexibleSpace: new FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 16.0, bottom: 16),
                      title: Text(
                        _title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  actions: <Widget>[
                    Builder(
                      builder: (BuildContext context) {
                        if (!isToday) {
                          return IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              _controller.animateToPage(
                                _todayIndex,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context).push<void>(
                            MaterialPageRoute(builder: (_) => SettingsPage()));
                      },
                    ),
                  ]),
              SliverList(
                delegate: SliverChildListDelegate(
                  _widgets,
                ),
              ),
            ],
          ),
        );
      });
      if (_todayIndex == null) {
        _todayIndex = 3;
        _timeErrorSnackBarMemoizer.runOnce(() => Future.delayed(
            Duration.zero,
            () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("기기의 시계가 어긋나 있습니다."),
                  duration: const Duration(seconds: 10),
                  backgroundColor: Colors.redAccent,
                ))));
      }
      _controller = PageController(initialPage: _todayIndex);
      return PageView(children: _pages, controller: _controller);
    } catch (e) {
      print(e);
      Future.delayed(Duration.zero, () {
        Cache().clear();
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("오류 발생"),
              content: new Text("데이터를 처리하는 중 오류가 발생했습니다."),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("앱 종료"),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                ),
              ],
            );
          },
        );
      });
      return SizedBox.shrink();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      asyncMethod();
    });
  }

  @override
  void didPopNext() {
    setState(() {
      asyncMethod();
    });
  }

  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).primaryColor);
    if (Theme.of(context).brightness == Brightness.light) {
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center));
            }

            if (snapshot.hasData) {
              if (snapshot.data == null) {
                return Center(
                    child: Text('데이터를 불러올 수 없음', textAlign: TextAlign.center));
              }
              return makePages(snapshot.data);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
