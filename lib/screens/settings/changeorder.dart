// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/shared_preferences.dart';

class ChangeOrderPage extends StatefulWidget {
  @override
  _ChangeOrderPageState createState() => _ChangeOrderPageState();
}

class _ChangeOrderPageState extends State<ChangeOrderPage> {
  Prefs _prefs;
  ScrollController _scrollController;

  Map _sectionsKO = {
    "Meal": "급식",
    "Timetable": "시간표",
    "Schedule": "학사일정",
  };

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
                          "화면 순서 변경",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Divider(),
                      ListTile(
                        title: Text('끌어다 놓아 순서 변경'),
                        subtitle: Transform.translate(
                          offset: Offset(0, 10),
                          child:
                              Text('아래 항목들을 길게 누르고 끌어다 놓아 화면 순서를 바꿀 수 있습니다.'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: const Text('기본값으로 복원'),
                            onPressed: () => setState(() {
                              _prefs.sectionOrder =
                                  Prefs.defaultValue().sectionOrder;
                              SharedPrefs().push(_prefs);
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      Divider(),
                      Container(
                        height: 200,
                        child: ReorderableListView(
                          children: _prefs.sectionOrder
                              .map((item) => ListTile(
                                    key: Key(item),
                                    title: Text("${_sectionsKO[item]}"),
                                    trailing: Icon(Icons.menu),
                                  ))
                              .toList(),
                          onReorder: (int start, int current) {
                            setState(() {
                              // dragging from top to bottom
                              if (start < current) {
                                int end = current - 1;
                                String startItem = _prefs.sectionOrder[start];
                                int i = 0;
                                int local = start;
                                do {
                                  _prefs.sectionOrder[local] =
                                      _prefs.sectionOrder[++local];
                                  i++;
                                } while (i < end - start);
                                _prefs.sectionOrder[end] = startItem;
                              }
                              // dragging from bottom to top
                              else if (start > current) {
                                String startItem = _prefs.sectionOrder[start];
                                for (int i = start; i > current; i--) {
                                  _prefs.sectionOrder[i] =
                                      _prefs.sectionOrder[i - 1];
                                }
                                _prefs.sectionOrder[current] = startItem;
                              }
                              SharedPrefs().push(_prefs);
                            });
                          },
                        ),
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
