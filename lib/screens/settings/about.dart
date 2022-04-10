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
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'package:hdmeal/utils/launch.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with RouteAware {
  late PackageInfo _packageInfo;
  late ScrollController _scrollController;

  final DateTime _now = DateTime.now();
  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  final newVersion = NewVersion();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        if (!kIsWeb) {
          _packageInfo = await PackageInfo.fromPlatform();
        }
        return true;
      });

  Future<VersionStatus?> _checkForUpdate() async {
    return await newVersion.getVersionStatus();
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

  List<Widget> _platformSpecificInfo() {
    if (kIsWeb) {
      return [
        ListTile(
          title: Text("흥덕고 급식 웹 클라이언트"),
        ),
      ];
    } else {
      return [
        ListTile(
          title: Text(
              "버전 ${_packageInfo.version}(Build ${_packageInfo.buildNumber})"),
        ),
        FutureBuilder(
            future: _checkForUpdate(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                return ListTile(
                  title: Text("업데이트를 확인할 수 없습니다."),
                );
              }

              if (snapshot.hasData) {
                VersionStatus _status = snapshot.data as VersionStatus;
                if (_status.canUpdate) {
                  return ListTile(
                    title: Text("업데이트가 있습니다. (버전 ${_status.storeVersion})"),
                    onTap: () async {
                      urlLauncher.launch(_status.appStoreLink);
                    },
                  );
                } else {
                  return ListTile(
                    title: Text("최신 버전입니다."),
                    onTap: () async {
                      if (_status.releaseNotes != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: new Text("릴리즈 노트 (버전 ${_status.storeVersion})"),
                              content: new Text(_status.releaseNotes!),
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
                      }
                    },
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
                    backgroundColor: Theme.of(context).primaryColor,
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
                  SliverSafeArea(
                    top: false,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        ..._platformSpecificInfo(),
                        Divider(),
                        ListTile(
                          title: Text('홈페이지 방문하기'),
                          onTap: () async {
                            launch(context, "https://hdml.kr/");
                          },
                        ),
                        Visibility(
                          child: ListTile(
                            title: Text('웹 앱 열기'),
                            onTap: () async {
                              launch(context, "https://go.hdml.kr/webapp");
                            },
                          ),
                          visible: !kIsWeb,
                        ),
                        Visibility(
                          child: ListTile(
                            title: Text('Google Play에서 앱 다운받기'),
                            onTap: () async {
                              launch(context, "https://get.hdml.kr/android");
                            },
                          ),
                          visible: kIsWeb,
                        ),
                        ListTile(
                          title: Text('소스 코드 보기'),
                          onTap: () async {
                            launch(
                                context, "https://go.hdml.kr/github/android");
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
                              launch(context,
                                  "https://go.hdml.kr/privacy/android");
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
    );
  }
}
