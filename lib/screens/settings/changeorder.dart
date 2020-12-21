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
import 'package:hdmeal/utils/shared_preferences.dart';

class ChangeOrderPage extends StatefulWidget {
  @override
  _ChangeOrderPageState createState() => _ChangeOrderPageState();
}

class _ChangeOrderPageState extends State<ChangeOrderPage> {
  Prefs _prefs;

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

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "화면 순서 변경",
        ),
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
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('끌어다 놓아 순서 바꾸기'),
                          subtitle:
                              Text('아래 항목들을 길게 누르고 끌어다 놓아 화면 순서를 바꿀 수 있습니다.'),
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
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
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
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
