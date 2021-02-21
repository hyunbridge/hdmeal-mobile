// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prefs _$PrefsFromJson(Map<String, dynamic> json) {
  return Prefs(
    json['userGrade'] as int,
    json['userClass'] as int,
    json['allergyInfo'] as bool,
    (json['sectionOrder'] as List).map((e) => e as String).toList(),
    json['receiveNotifications'] as bool,
    json['notificationsHour'] as int,
    json['notificationsMinute'] as int,
    json['showMyScheduleOnly'] as bool,
    json['theme'] as String,
    json['enableBlackTheme'] as bool,
  );
}

Map<String, dynamic> _$PrefsToJson(Prefs instance) => <String, dynamic>{
      'userGrade': instance.userGrade,
      'userClass': instance.userClass,
      'allergyInfo': instance.allergyInfo,
      'sectionOrder': instance.sectionOrder,
      'receiveNotifications': instance.receiveNotifications,
      'notificationsHour': instance.notificationsHour,
      'notificationsMinute': instance.notificationsMinute,
      'showMyScheduleOnly': instance.showMyScheduleOnly,
      'theme': instance.theme,
      'enableBlackTheme': instance.enableBlackTheme,
    };
