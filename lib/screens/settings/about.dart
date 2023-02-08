// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'package:hdmeal/utils/launch.dart';
import 'package:hdmeal/utils/update_checker.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with RouteAware {
  late PackageInfo _packageInfo;
  late ScrollController _scrollController;

  final DateTime _now = DateTime.now();
  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _packageInfo = await PackageInfo.fromPlatform();
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

  List<Widget> _platformSpecificInfo() {
    if (kIsWeb) {
      return [
        ListTile(
          title: Text("흥덕고 급식 웹 클라이언트"),
        ),
      ];
    } else {
      return [
        FutureBuilder(
            future: checkForUpdate(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                return ListTile(
                  title: Text("업데이트를 확인할 수 없습니다."),
                );
              }

              if (snapshot.hasData) {
                VersionStatus _status = snapshot.data as VersionStatus;
                if (_status.isUpdateAvailable) {
                  return ListTile(
                    title: Text("업데이트가 있습니다. (버전 ${_status.latestVersion})"),
                    onTap: () async {
                      urlLauncher.launch(
                          "https://play.google.com/store/apps/details?id=kr.hdml.app");
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
      ];
    }
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
                                "흥덕고 급식",
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
                            ListTile(
                              title: Text(
                                  "버전 ${_packageInfo.version}(Build ${_packageInfo.buildNumber})"),
                            ),
                            ..._platformSpecificInfo(),
                            Divider(),
                            ListTile(
                              title: Text('홈페이지 방문하기'),
                              onTap: () async {
                                launch(context, "https://hdmeal.hgseo.net/");
                              },
                            ),
                            Visibility(
                              child: ListTile(
                                title: Text('웹 앱 열기'),
                                onTap: () async {
                                  launch(
                                      context, "https://hdmeal.hgseo.net/app");
                                },
                              ),
                              visible: !kIsWeb,
                            ),
                            Visibility(
                              child: ListTile(
                                title: Text('Google Play에서 앱 다운받기'),
                                onTap: () async {
                                  launch(context,
                                      "https://hdmeal.hgseo.net/android");
                                },
                              ),
                              visible: kIsWeb,
                            ),
                            ListTile(
                              title: Text('소스 코드 보기'),
                              onTap: () async {
                                launch(context,
                                    "https://hdmeal.hgseo.net/gh/mobile");
                              },
                            ),
                            ListTile(
                              title: Text('개발자에게 문의하기'),
                              onTap: () async {
                                urlLauncher
                                    .launch("mailto:hekn2y4j@duck.com");
                              },
                            ),
                            Divider(),
                            ListTile(
                              title: Text('저작권'),
                              subtitle: Text(
                                  "Copyright 2020-${_now.year} Hyungyo Seo"),
                            ),
                            ListTile(
                                title: Text('개인정보 처리방침'),
                                onTap: () async {
                                  launch(context,
                                      "https://hdmeal.hgseo.net/privacy/mobile");
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
