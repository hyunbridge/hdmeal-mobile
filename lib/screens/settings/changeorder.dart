// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

import '/utils/preferences_manager.dart';

class ChangeOrderPage extends StatefulWidget {
  @override
  _ChangeOrderPageState createState() => _ChangeOrderPageState();
}

class _ChangeOrderPageState extends State<ChangeOrderPage> {
  late ScrollController _scrollController;

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
                        "화면 순서 변경",
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
              ReorderableSliverList(
                delegate: ReorderableSliverChildListDelegate(
                    _prefsManager.prefs.sectionOrder
                        .map<Widget>((e) => ListTile(
                              title: Text(_sectionsKO[e]),
                              trailing: Icon(Icons.menu),
                            ))
                        .toList()),
                onReorder: (oldIndex, newIndex) {
                  final _sectionOrder =
                      List<String>.from(_prefsManager.prefs.sectionOrder);
                  setState(() {
                    String section = _sectionOrder.removeAt(oldIndex);
                    _sectionOrder.insert(newIndex, section);
                  });
                  _prefsManager.set('sectionOrder', _sectionOrder);
                },
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Divider(),
                    ListTile(
                      title: Text('기본값으로 복원'),
                      onTap: () =>
                          setState(() => _prefsManager.reset('sectionOrder')),
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
