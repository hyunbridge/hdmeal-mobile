// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

import 'package:hdmeal/models/preferences.dart';
import 'package:hdmeal/utils/shared_preferences.dart';
import 'package:hdmeal/utils/menu_notification.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettingsPage> {
  Prefs _prefs;

  final MenuNotification _notification = new MenuNotification();

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        _prefs = await SharedPrefs().pull();
        await _notification.init();
        return true;
      });

  Future<void> _schedule(int hour, int minute) async {
    await _notification.unsubscribe();
    if (_prefs.receiveNotifications) {
      await _notification.subscribe(hour, minute);
    }
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  Widget build(BuildContext context) {
    ThemeData _themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: _themeData.primaryColor,
      appBar: AppBar(
        title: Text(
          "알림 설정",
        ),
      ),
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
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('매일 알림 받기'),
                          subtitle: Text('매일 지정된 시각에 알림을 받아볼 수 있습니다.'
                              ' 오랫동안 앱을 실행하지 않았거나 절전 모드를'
                              ' 실행하여 백그라운드에서 앱이 실행될 수 없는'
                              ' 경우 알림이 발송되지 않을 수 있습니다.'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: const Text('기본값으로 복원'),
                              onPressed: () {
                                setState(() {
                                  _prefs.receiveNotifications =
                                      Prefs.defaultValue().receiveNotifications;
                                  _prefs.notificationsHour =
                                      Prefs.defaultValue().notificationsHour;
                                  _prefs.notificationsMinute =
                                      Prefs.defaultValue().notificationsMinute;
                                  SharedPrefs().push(_prefs);
                                });
                                _schedule(_prefs.notificationsHour,
                                    _prefs.notificationsMinute);
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                      child: ListView(
                    children: [
                      SwitchListTile(
                        title: const Text('알림 받기'),
                        value: _prefs.receiveNotifications,
                        onChanged: (bool value) {
                          setState(() {
                            _prefs.receiveNotifications = value;
                            SharedPrefs().push(_prefs);
                          });
                        },
                      ),
                      ListTile(
                        title: Text('알림 받을 시간'),
                        subtitle: Text(
                            '${_prefs.notificationsHour}시 ${_prefs.notificationsMinute}분'),
                        onTap: () async {
                          DateTime _time = DateTime(
                              1970,
                              1,
                              1,
                              _prefs.notificationsHour,
                              _prefs.notificationsMinute);
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("알림 받을 시간 설정"),
                                content: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(":",
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: _themeData
                                              .textTheme.bodyText1.color,
                                        )),
                                    Transform.translate(
                                      offset: const Offset(-4, 0),
                                      child: TimePickerSpinner(
                                        time: _time,
                                        normalTextStyle: TextStyle(
                                          fontSize: 24,
                                          color: Colors.grey,
                                        ),
                                        highlightedTextStyle: TextStyle(
                                          fontSize: 24,
                                          color: _themeData
                                              .textTheme.bodyText1.color,
                                        ),
                                        spacing: 15,
                                        itemHeight: 45,
                                        itemWidth: 40,
                                        isForce2Digits: true,
                                        minutesInterval: 5,
                                        onTimeChange: (time) {
                                          _time = time;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("닫기"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          setState(() {
                            _prefs.notificationsHour = _time.hour;
                            _prefs.notificationsMinute = _time.minute;
                            SharedPrefs().push(_prefs);
                          });
                          _schedule(_prefs.notificationsHour,
                              _prefs.notificationsMinute);
                        },
                      ),
                      ListTile(
                        title: Text('알림 미리보기'),
                        onTap: () async {
                          _notification.show();
                        },
                      ),
                    ],
                  )),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
