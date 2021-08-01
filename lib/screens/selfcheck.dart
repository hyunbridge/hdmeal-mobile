// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SelfCheckPage extends StatefulWidget {
  @override
  _SelfCheckPageState createState() => _SelfCheckPageState();
}

class _SelfCheckPageState extends State<SelfCheckPage> {
  ScrollController _scrollController;

  final _storage = new FlutterSecureStorage();

  String name;
  String birth;
  String password;

  bool isWorking = false;

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

  void _readStorage() async {
    final all = await _storage.readAll();
    setState(() {
      name = all["hcsName"];
      birth = all["hcsBirth"];
      password = all["hcsPassword"];
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _readStorage();
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
                    "간편 자가진단",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/selfCheck/settings');
                    _readStorage();
                  },
                ),
              ]),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                title: Text(
                  '아래의 설문 문항 중 하나라도 해당사항이 있다면 즉시 담임선생님께 알리고 등교를 중지해야 합니다.\n'
                  '자가진단 프로필: ${name ?? '(없음)'}',
                  style: TextStyle(height: 1.5),
                ),
                visualDensity: VisualDensity(vertical: 4),
              ),
              Divider(),
              ListTile(
                title: Text(
                  '1. 학생 본인이 코로나19가 의심되는 아래의 임상증상*이 있나요?',
                  style: TextStyle(height: 1.5),
                ),
                subtitle: Text(
                  '* (주요 임상증상) 체온 37.5℃ 이상, 기침, 호흡곤란, 오한, 근육통, 두통, 인후통,후각·미각 소실 또는 폐렴.\n'
                  '* (단, 코로나19와 관계없이 평소의 기저질환으로 인한 증상인 경우는 제외)',
                  style: TextStyle(height: 1.5),
                ),
                visualDensity: VisualDensity(vertical: 4),
              ),
              ListTile(
                title: Text(
                  '2. 학생 본인 또는 동거인이 코로나19 의심증상으로 진단검사를 받고 그 결과를 기다리고 있나요?',
                  style: TextStyle(height: 1.5),
                ),
                visualDensity: VisualDensity(vertical: 4),
              ),
              ListTile(
                title: Text(
                  '3. 학생 본인 또는 동거인이 방역당국에 의해 현재 자가격리가 이루어지고 있나요?',
                  style: TextStyle(height: 1.5),
                ),
                subtitle: Text(
                  '※ <방역당국 지침> 최근 14일 이내 해외 입국자, 확진자와 접촉자 등은 자가격리 조치\n'
                  '단, 직업특성상 잦은 해외 입·출국으로 의심증상이 없는 경우 자가격리 면제',
                  style: TextStyle(height: 1.5),
                ),
                visualDensity: VisualDensity(vertical: 4),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 60,
        child: BottomAppBar(
          elevation: 8,
          shape: CircularNotchedRectangle(),
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                  onPressed: () async {
                    if (!isWorking) {
                      if (name == null || birth == null || password == null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: new Text("프로필 없음"),
                              content:
                                  new Text("화면 우상단의 버튼을 눌러 프로필을 입력해 주세요."),
                              actions: <Widget>[
                                new TextButton(
                                  child: new Text("확인"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      setState(() => isWorking = true);
                      final reqPayload = <String, String>{
                        'name': name,
                        'birth': birth,
                        'school_area': '경기도',
                        'school_name': '흥덕고등학교',
                        'school_level': '고등학교',
                        'password': password,
                      };
                      http.Response response = await http.post(
                        Uri.parse("https://api.hdml.kr/self-check/self-check/"),
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(reqPayload),
                      );
                      final resBody = utf8.decode(response.bodyBytes);
                      final resPayload = json.decode(resBody);
                      if (resPayload['code'] == "SUCCESS") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: new Text("자가진단 설문지를 제출했습니다."),
                              content:
                                  new Text("$name, ${resPayload['regtime']}"),
                              actions: <Widget>[
                                new TextButton(
                                  child: new Text("확인"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: new Text("자가진단 설문지 제출에 실패했습니다."),
                              content: new Text(
                                  "서버측 오류 메세지: ${resPayload['message']}"),
                              actions: <Widget>[
                                new TextButton(
                                  child: new Text("확인"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      setState(() => isWorking = false);
                    }
                  },
                  child: isWorking
                      ? SizedBox(
                          child: CircularProgressIndicator(),
                          height: 20,
                          width: 20,
                        )
                      : Text("해당 없음")),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
