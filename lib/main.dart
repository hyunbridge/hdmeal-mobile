import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: "SpoqaHanSansNeo",
      brightness: Brightness.light,
      primaryColor: Colors.white,
      primarySwatch: Colors.grey,
    ),
    darkTheme: ThemeData(
      fontFamily: "SpoqaHanSansNeo",
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      primarySwatch: Colors.grey,
      accentColor: Colors.grey[500],
      toggleableActiveColor: Colors.grey[500],
      // 다크 테마에서는 primarySwatch가 먹지 않음
    ),
    home: HomePage(),
    navigatorObservers: [routeObserver],
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  SharedPreferences _prefs;
  var _grade;
  var _class;

  Future fetchData(http.Client client) async {
    try {
      final response =
          await client.get('https://static.api.hdml.kr/data.v2.json');
      return json.decode(response.body);
    } on SocketException {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("서버에 연결할 수 없음"),
            content: new Text("장치의 인터넷 연결 상태를 확인해 주세요."),
            actions: <Widget>[
              new FlatButton(
                child: new Text("앱 종료"),
                onPressed: () {
                  Navigator.pop(context);
                  exit(0);
                },
              ),
            ],
          );
        },
      );
    }
    return null;
  }

  pullFromSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _grade = _prefs.getInt("Grade") ?? 1;
      _class = _prefs.getInt("Class") ?? 1;
    });
  }

  makePages(data) {
    List<Widget> _pages = [];
    var _todayIndex;
    data.forEach((date, data) {
      // 날짜 처리
      const _weekday = ["", "월", "화", "수", "목", "금", "토", "일"];
      var _now = DateTime.now();
      var _parsedDate = DateTime.parse(date);
      if (_now.day - _parsedDate.day == 0) {
        _todayIndex = _pages.length;
      }
      var _title =
          "${_parsedDate.month}월 ${_parsedDate.day}일(${_weekday[_parsedDate.weekday]})";
      // 식단 리스트 작성
      var _menuList = [];
      var _menu = data["Meal"][0] ?? ["식단정보가 없습니다."];
      _menu.forEach((element) => _menuList.add(ListTile(
            title: Text(element),
            visualDensity: VisualDensity(vertical: -4),
          )));
      // 시간표 리스트 작성
      var _timetableList = [];
      var _timetable = data["Timetable"]["$_grade"]["$_class"];
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
      var _scheduleList = [];
      var _schedule = data["Schedule"] ?? ["학사일정이 없습니다."];
      _schedule.forEach((element) => _scheduleList.add(ListTile(
            title: Text(element),
            visualDensity: VisualDensity(vertical: -4),
          )));
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
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).push<void>(_createSettingsRoute());
                    },
                  ),
                ]),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ListTile(
                    title: Text(
                      "급식",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._menuList,
                  Divider(),
                  ListTile(
                    title: Text(
                      "$_grade학년 $_class반 시간표",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._timetableList,
                  Divider(),
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
                ],
              ),
            ),
          ],
        ),
      );
    });
    return PageView(
        children: _pages, controller: PageController(initialPage: _todayIndex));
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
    pullFromSharedPrefs();
  }

  @override
  void didPopNext() {
    pullFromSharedPrefs();
  }

  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Theme.of(context).primaryColor);
    FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).primaryColor);
    if (Theme.of(context).brightness == Brightness.light) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder(
          future: fetchData(http.Client()),
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

// Settings
Route _createSettingsRoute() {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(),
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

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences _prefs;
  var _gradeSelection;
  var _classSelection;
  var _appVersion;

  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
  }

  pushToSharedPrefs() async {
    await _prefs.setInt("Grade", _gradeSelection);
    await _prefs.setInt("Class", _classSelection);
  }

  pullFromSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _gradeSelection = _prefs.getInt("Grade") ?? 1;
      _classSelection = _prefs.getInt("Class") ?? 1;
    });
  }

  @override
  void initState() {
    super.initState();
    pullFromSharedPrefs();
    getAppVersion();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "설정",
        ),
      ),
      body: ListView(
        children: [
          PopupMenuButton<int>(
            onSelected: (int value) {
              setState(() {
                _gradeSelection = value;
                pushToSharedPrefs();
              });
            },
            child: ListTile(
              title: Text('학년'),
              subtitle: Text("$_gradeSelection학년"),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
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
                _classSelection = value;
                pushToSharedPrefs();
              });
            },
            child: ListTile(
              title: Text('반'),
              subtitle: Text("$_classSelection반"),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
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
      ),
    );
  }
}
