// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_update/in_app_update.dart';

class AppInfoPage extends StatefulWidget {
  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> with RouteAware {
  PackageInfo _packageInfo;
  ScrollController _scrollController;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _packageInfo = await PackageInfo.fromPlatform();
        return true;
      });

  Future<AppUpdateInfo> _checkForUpdate() async {
    return await InAppUpdate.checkForUpdate();
  }

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
                          "흥덕고 급식",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ListTile(
                        title: Text(
                            "버전 ${_packageInfo.version}(Build ${_packageInfo.buildNumber})"),
                      ),
                      FutureBuilder(
                          future: _checkForUpdate(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Center(
                                  child: Text('Error: ${snapshot.error}',
                                      textAlign: TextAlign.center));
                            }

                            if (snapshot.hasData) {
                              if (snapshot.data.updateAvailable) {
                                return ListTile(
                                  title: Text("업데이트가 있습니다."),
                                  onTap: () async {
                                    launch("market://details?id=" +
                                        _packageInfo.packageName);
                                  },
                                );
                              } else {
                                return ListTile(
                                  title: Text("최신 버전입니다."),
                                );
                              }
                            } else {
                              return ListTile(
                                title: Text("업데이트 확인 중..."),
                                trailing: Transform.scale(
                                  scale: 0.5,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          }),
                      Divider(),
                      ListTile(
                        title: Text('웹 앱 열기'),
                        onTap: () async {
                          launch("https://app.hdml.kr/");
                        },
                      ),
                      ListTile(
                        title: Text('소스 코드 보기'),
                        onTap: () async {
                          launch("https://github.com/hgyoseo/HDMeal-Flutter");
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
                        title: Text('저작권'),
                        subtitle: Text("Copyright (c) 2020 Hyungyo Seo."),
                      ),
                      ListTile(
                        title: Text('개인정보 처리방침'),
                        onTap: () async {
                          launch(
                              "https://hdmeal.page.link/FlutterAppPrivacyPolicy");
                        },
                      ),
                      ListTile(
                        title: Text('오픈소스 라이선스'),
                        onTap: () async {
                          Navigator.pushNamed(
                              context, '/settings/appInfo/OSSLicences');
                        },
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
