// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:intl/intl.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:hdmeal/utils/fetch.dart';

class MenuNotification {
  String _channelId;
  final List<String> _weekday = ["", "월", "화", "수", "목", "금", "토", "일"];
  final DateFormat _utcFormatter = DateFormat('yyyy-MM-dd');

  final FetchData _fetch = new FetchData();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  NotificationDetails _notificationDetails;

  Future<void> init() async {
    final PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    _channelId = '${_packageInfo.packageName}-Menu';

    const AndroidInitializationSettings _androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    final _settings = InitializationSettings(android: _androidSettings);

    _notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            _channelId, '아침인사', '매일 지정한 시간에 보내 드리는 알림입니다.',
            importance: Importance.max, priority: Priority.high));

    await _localNotifications.initialize(_settings);
  }

  Future<void> show() async {
    final DateTime _now = DateTime.now();
    try {
      await _localNotifications.show(
        0,
        "${_now.month}월 ${_now.day}일(${_weekday[_now.weekday]})",
        "오늘의 급식과 시간표를 확인해 보세요.",
        _notificationDetails,
      );
    } on NoSuchMethodError {
      // pass
    }
  }

  Future<void> clear() async {
    await _localNotifications.cancelAll();
  }

  Future<void> subscribe(int hour, int minute) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    final _now = tz.TZDateTime.now(tz.local);
    final String _cacheKey = _utcFormatter.format(_now);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup(_channelId);
    try {
      final Map _menuData = await _fetch.fetchFromCache();
      if (_menuData[_cacheKey]["Meal"][0] == null) {
        throw NoSuchMethodError;
      }
      await _localNotifications.zonedSchedule(
        0,
        "${_now.month}월 ${_now.day}일(${_weekday[_now.weekday]})",
        "오늘의 급식과 시간표를 확인해 보세요.",
        tz.TZDateTime(tz.local, _now.year, _now.month, _now.day, hour, minute),
        _notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on NoSuchMethodError {
      // pass
    }
  }

  Future<void> unsubscribe() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup(_channelId);
  }
}
