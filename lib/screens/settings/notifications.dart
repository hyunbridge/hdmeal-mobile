// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

import 'package:hdmeal/utils/preferences_manager.dart';
import 'package:hdmeal/utils/menu_notification.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettingsPage> {
  ScrollController _scrollController;

  final PrefsManager _prefsManager = PrefsManager();

  final MenuNotification _notification = MenuNotification();

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();

  Future asyncMethod() => _asyncMemoizer.runOnce(() async {
        await _notification.init();
        return true;
      });

  Future<void> _schedule(int hour, int minute) async {
    await _notification.unsubscribe();
    if (_prefsManager.get('receiveNotifications')) {
      await _notification.subscribe(hour, minute);
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
    asyncMethod();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  Widget build(BuildContext context) {
    ThemeData _themeData = Theme.of(context);
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
                          "알림 설정",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Divider(),
                      ListTile(
                        title: Text('매일 지정한 시각에 알림 받기'),
                        subtitle: Transform.translate(
                          offset: Offset(0, 10),
                          child: Text('오랫동안 앱을 실행하지 않았거나 절전 모드를'
                              ' 실행하여 백그라운드에서 앱이 실행될 수 없는'
                              ' 경우 알림이 발송되지 않을 수 있습니다.'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: const Text('기본값으로 복원'),
                            onPressed: () {
                              setState(() {
                                _prefsManager.reset('receiveNotifications');
                                _prefsManager.reset('notificationsHour');
                                _prefsManager.reset('notificationsMinute');
                              });
                              _schedule(_prefsManager.get('notificationsHour'),
                                  _prefsManager.get('notificationsMinute'));
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      Divider(),
                      SwitchListTile(
                        title: const Text('알림 받기'),
                        value: _prefsManager.get('receiveNotifications'),
                        onChanged: (bool value) {
                          setState(() =>
                              _prefsManager.set('receiveNotifications', value));
                        },
                      ),
                      ListTile(
                        title: Text('알림 받을 시간'),
                        subtitle: Text(
                            '${_prefsManager.get('notificationsHour')}시 ${_prefsManager.get('notificationsMinute')}분'),
                        onTap: () async {
                          DateTime _time = DateTime(
                              1970,
                              1,
                              1,
                              _prefsManager.get('notificationsHour'),
                              _prefsManager.get('notificationsMinute'));
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
                                  TextButton(
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
                            _prefsManager.set('notificationsHour', _time.hour);
                            _prefsManager.set(
                                'notificationsMinute', _time.minute);
                          });
                          _schedule(_prefsManager.get('notificationsHour'),
                              _prefsManager.get('notificationsMinute'));
                        },
                      ),
                      ListTile(
                        title: Text('알림 미리보기'),
                        onTap: () async {
                          _notification.show();
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
