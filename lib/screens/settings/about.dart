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
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as customTabs;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:in_app_update/in_app_update.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with RouteAware {
  PackageInfo _packageInfo;
  ScrollController _scrollController;

  final DateTime _now = DateTime.now();
  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _packageInfo = await PackageInfo.fromPlatform();
        return true;
      });

  Future<AppUpdateInfo> _checkForUpdate() async {
    return await InAppUpdate.checkForUpdate();
  }

  void _launch(BuildContext context, String _url) async {
    try {
      await customTabs.launch(
        _url,
        option: new customTabs.CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          extraCustomTabs: <String>[
            'com.brave.browser',
            'com.microsoft.emmx',
            'com.sec.android.app.sbrowser',
            'org.mozilla.firefox',
          ],
        ),
      );
    } catch (_) {
      urlLauncher.launch(_url);
    }
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
                                    urlLauncher.launch("market://details?id=" +
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
                        title: Text('홈페이지 방문하기'),
                        onTap: () async {
                          _launch(context, "https://hdml.kr/");
                        },
                      ),
                      ListTile(
                        title: Text('웹 앱 열기'),
                        onTap: () async {
                          _launch(context, "https://go.hdml.kr/webapp");
                        },
                      ),
                      ListTile(
                        title: Text('소스 코드 보기'),
                        onTap: () async {
                          _launch(context,
                              "https://go.hdml.kr/github/android");
                        },
                      ),
                      ListTile(
                        title: Text('개발자에게 문의하기'),
                        subtitle: Text("hekn2y4j@duck.com"),
                        onTap: () async {
                          urlLauncher.launch("mailto:hekn2y4j@duck.com");
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('저작권'),
                        subtitle:
                            Text("Copyright 2020-${_now.year} Hyungyo Seo"),
                      ),
                      ListTile(
                          title: Text('개인정보 처리방침'),
                          onTap: () async {
                            _launch(
                                context, "https://go.hdml.kr/privacy/android");
                          }),
                      ListTile(
                        title: Text('오픈소스 라이선스'),
                        onTap: () async {
                          Navigator.pushNamed(
                              context, '/settings/about/OSSLicences');
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
