// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hdmeal/oss_licenses.dart';

class OSSLicencesPage extends StatefulWidget {
  @override
  _OSSLicencesPageState createState() => _OSSLicencesPageState();
}

class _OSSLicencesPageState extends State<OSSLicencesPage> {
  ScrollController _scrollController;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        List<Widget> _ossList = [];
        ossLicenses.forEach((name, content) {
          _ossList.addAll([
            Divider(),
            ListTile(
                title: Text("$name (버전 ${content["version"]})",
                    style: Theme.of(context).textTheme.headline6)),
          ]);
          if (content["authors"].length > 0) {
            String _authors = "${content["authors"]}";
            _ossList.add(ListTile(
                title: Text("제작자"),
                subtitle: Text(_authors.substring(1, _authors.length - 1))));
          }
          if (content["license"] != "") {
            _ossList.add(ListTile(
              title: Text('라이선스 보기'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("$name의 라이선스"),
                      content: SingleChildScrollView(
                          child: new Text("${content["license"]}")),
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
          if (content["homepage"] != null) {
            _ossList.add(ListTile(
                title: Text('홈페이지 가기'),
                subtitle: Text(content["homepage"]),
                onTap: () async {
                  launch(content["homepage"]);
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

            if (snapshot.hasData) {
              if (snapshot.data == null) {
                return Center(
                    child: Text('데이터를 불러올 수 없음', textAlign: TextAlign.center));
              }
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
                          "오픈소스 라이선스",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ListTile(
                          title:
                              Text("흥덕고 급식 앱은 다양한 오픈 소스 프로젝트들을 활용하여 만들어졌습니다.")),
                      ...snapshot.data
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
