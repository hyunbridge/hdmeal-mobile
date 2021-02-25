// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';

import 'package:hdmeal/utils/preferences_manager.dart';

class ChangeOrderPage extends StatefulWidget {
  @override
  _ChangeOrderPageState createState() => _ChangeOrderPageState();
}

class _ChangeOrderPageState extends State<ChangeOrderPage> {
  ScrollController _scrollController;

  Map _sectionsKO = {
    "Meal": "급식",
    "Timetable": "시간표",
    "Schedule": "학사일정",
  };

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
                  child: Text('아래 항목들을 길게 누르고 끌어다 놓아 화면 순서를 바꿀 수 있습니다.'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('기본값으로 복원'),
                    onPressed: () =>
                        setState(() => _prefsManager.reset('sectionOrder')),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Divider(),
              Container(
                height: 200,
                child: ReorderableListView(
                  children: _prefsManager
                      .get('sectionOrder')
                      .map<Widget>((item) => ListTile(
                            key: Key(item),
                            title: Text("${_sectionsKO[item]}"),
                            trailing: Icon(Icons.menu),
                          ))
                      .toList(),
                  onReorder: (int start, int current) {
                    final List<String> _sectionOrder =
                        _prefsManager.get('sectionOrder');
                    // dragging from top to bottom
                    if (start < current) {
                      int end = current - 1;
                      String startItem = _sectionOrder[start];
                      int i = 0;
                      int local = start;
                      do {
                        _sectionOrder[local] = _sectionOrder[++local];
                        i++;
                      } while (i < end - start);
                      _sectionOrder[end] = startItem;
                    }
                    // dragging from bottom to top
                    else if (start > current) {
                      String startItem = _sectionOrder[start];
                      for (int i = start; i > current; i--) {
                        _sectionOrder[i] = _sectionOrder[i - 1];
                      }
                      _sectionOrder[current] = startItem;
                    }
                    setState(
                        () => _prefsManager.set('sectionOrder', _sectionOrder));
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
