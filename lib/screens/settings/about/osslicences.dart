// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:hdmeal/utils/launch.dart';
import 'package:hdmeal/oss_licenses.dart';

class OSSLicencesPage extends StatefulWidget {
  @override
  _OSSLicencesPageState createState() => _OSSLicencesPageState();
}

class _OSSLicencesPageState extends State<OSSLicencesPage> {
  late ScrollController _scrollController;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        List<Widget> _ossList = [];
        ossLicenses.forEach((Package package) {
          _ossList.addAll([
            Divider(),
            ListTile(
                title: Text("${package.name} (버전 ${package.version})",
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                    ))),
          ]);
          if (package.authors.length > 0) {
            String _authors = "${package.authors}";
            _ossList.add(ListTile(
                title: Text("제작자"),
                subtitle: Text(_authors.substring(1, _authors.length - 1))));
          }
          if (package.license != "") {
            _ossList.add(ListTile(
              title: Text('라이선스 보기'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("${package.name}의 라이선스"),
                      content: SingleChildScrollView(
                          child: new Text("${package.license}")),
                      actions: <Widget>[
                        new TextButton(
                          child: new Text("닫기"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ));
          }
          if (package.homepage != null) {
            _ossList.add(ListTile(
                title: Text('홈페이지 가기'),
                subtitle: Text(package.homepage!),
                onTap: () async {
                  launch(context, package.homepage!);
                }));
          }
        });
        return _ossList;
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
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: FutureBuilder(
              future: asyncMethod(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          textAlign: TextAlign.center));
                }

                if (snapshot.hasData) {
                  return CustomScrollView(
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
                              vertical: 14.0,
                              horizontal: _horizontalTitlePadding),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "오픈소스 라이선스",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverSafeArea(
                        top: false,
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Divider(),
                            ListTile(
                                title: Text(
                                    "흥덕고 급식 앱은 다양한 오픈 소스 프로젝트들을 활용하여 만들어졌습니다.")),
                            ...snapshot.data as List<Widget>
                          ]),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }
}
