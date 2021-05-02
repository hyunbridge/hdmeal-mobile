// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

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
          ReorderableSliverList(
            delegate: ReorderableSliverChildListDelegate(_prefsManager
                .get('sectionOrder')
                .map<Widget>((e) => ListTile(
                      title: Text(_sectionsKO[e]),
                      trailing: Icon(Icons.menu),
                    ))
                .toList()),
            onReorder: (oldIndex, newIndex) {
              final List<String> _sectionOrder =
                  _prefsManager.get('sectionOrder');
              setState(() {
                String section = _sectionOrder.removeAt(oldIndex);
                _sectionOrder.insert(newIndex, section);
              });
              _prefsManager.set('sectionOrder', _sectionOrder);
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Divider(),
              ListTile(
                title: Text('기본값으로 복원'),
                onTap: () =>
                    setState(() => _prefsManager.reset('sectionOrder')),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
