// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:shimmer/shimmer.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:hdmeal/utils/cache.dart';
import 'package:hdmeal/utils/fetch.dart';
import 'package:hdmeal/utils/preferences_manager.dart';
import 'package:hdmeal/extensions/date_only_compare.dart';
import 'package:hdmeal/widgets/change_grade_class.dart';
import 'package:hdmeal/widgets/sections.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final FirebaseAnalytics analytics = FirebaseAnalytics();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final PrefsManager _prefsManager = PrefsManager();

  final FetchData _fetch = FetchData();

  final AsyncMemoizer _fetchDataMemoizer = AsyncMemoizer();
  final AsyncMemoizer _timeErrorSnackBarMemoizer = AsyncMemoizer();

  void asyncMethod() async {
    _prefsManager.serialize().forEach((key, value) {
      if (key != "userGrade" &&
          key != "userClass" &&
          key != "highlightedKeywords") {
        analytics.setUserProperty(name: key, value: '$value');
      }
    });
  }

  Future fetchData() => _fetchDataMemoizer.runOnce(() async {
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
                  new TextButton(
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
    try {
      data.forEach((date, data) {
        // 날짜 처리
        bool isToday = false;
        final DateTime _now = DateTime.now();
        final DateTime _parsedDate = DateTime.parse(date);
        if (_now.isSameDate(_parsedDate)) {
          _todayIndex = _pages.length;
          isToday = true;
        }
        final _title =
            "${_parsedDate.month}월 ${_parsedDate.day}일(${_weekday[_parsedDate.weekday]})";
        // 섹션 내부 작성
        final _widgets = <Widget>[];
        final _sections = {
          "Meal": menuSection(
            context: context,
            date: _parsedDate,
            menu: data["Meal"][0] ?? [],
            showAllergyInfo: _prefsManager.get('allergyInfo'),
            enableKeywordHighlight: _prefsManager.get("enableKeywordHighlight"),
            highlightedKeywords: _prefsManager.get("highlightedKeywords"),
          ),
          "Timetable": timetableSection(
            context: context,
            userGrade: _prefsManager.get('userGrade'),
            userClass: _prefsManager.get('userClass'),
            timetable: data["Timetable"]["${_prefsManager.get('userGrade')}"]
                ["${_prefsManager.get('userClass')}"],
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ChangeGradeClass(
                    currentGrade: _prefsManager.get('userGrade'),
                    currentClass: _prefsManager.get('userClass'),
                    onChanged: (selectedGrade, selectedClass) => setState(() {
                      _prefsManager.set('userGrade', selectedGrade);
                      _prefsManager.set('userClass', selectedClass);
                    }),
                  );
                },
              );
            },
          ),
          "Schedule": scheduleSection(
            context: context,
            userGrade: _prefsManager.get('userGrade'),
            schedule: data["Schedule"] ?? [],
            showMyScheduleOnly: _prefsManager.get('showMyScheduleOnly'),
          )
        };
        _prefsManager.get('sectionOrder').forEach((element) {
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
                      titlePadding: EdgeInsets.only(left: 16.0, bottom: 13),
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
                        Navigator.pushNamed(context, '/settings');
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
      return PageView(
        children: _pages,
        controller: _controller,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
      );
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
                new TextButton(
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
    Color _shimmerBaseColor;
    Color _shimmerHighlightColor;
    final Random _random = new Random();
    if (!kIsWeb) {
      FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      FlutterStatusbarcolor.setNavigationBarColor(
          Theme.of(context).primaryColor);
      switch (Theme.of(context).brightness) {
        case Brightness.light:
          _shimmerBaseColor = Colors.grey[300];
          _shimmerHighlightColor = Colors.grey[100];
          FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
          break;
        case Brightness.dark:
          _shimmerBaseColor = Colors.grey[800];
          _shimmerHighlightColor = Colors.grey[600];
          FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
          break;
      }
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
              return CustomScrollView(
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
                          titlePadding: EdgeInsets.only(left: 16.0, bottom: 13),
                          title: Shimmer.fromColors(
                              child: Container(
                                width: 140,
                                height: 30,
                                color: Colors.white,
                              ),
                              baseColor: _shimmerBaseColor,
                              highlightColor: _shimmerHighlightColor)),
                      actions: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ]),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Shimmer.fromColors(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                height: 35,
                                width: _random.nextDouble() * 250 + 150,
                                color: Colors.white,
                              ),
                            ),
                            baseColor: _shimmerBaseColor,
                            highlightColor: _shimmerHighlightColor);
                      },
                      childCount: _random.nextInt(5) + 10,
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
