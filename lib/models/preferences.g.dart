// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prefs _$PrefsFromJson(Map<String, dynamic> json) {
  return Prefs(
    json['allergyInfo'] as bool,
    json['enableBlackTheme'] as bool,
    json['enableDataSaver'] as bool,
    (json['sectionOrder'] as List).map((e) => e as String).toList(),
    json['showMyScheduleOnly'] as bool,
    json['theme'] as String,
    json['userClass'] as int,
    json['userGrade'] as int,
  );
}

Map<String, dynamic> _$PrefsToJson(Prefs instance) => <String, dynamic>{
      'allergyInfo': instance.allergyInfo,
      'enableBlackTheme': instance.enableBlackTheme,
      'enableDataSaver': instance.enableDataSaver,
      'sectionOrder': instance.sectionOrder,
      'showMyScheduleOnly': instance.showMyScheduleOnly,
      'theme': instance.theme,
      'userClass': instance.userClass,
      'userGrade': instance.userGrade,
    };
