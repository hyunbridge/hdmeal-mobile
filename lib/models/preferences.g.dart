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
  );
}

Map<String, dynamic> _$PrefsToJson(Prefs instance) => <String, dynamic>{
      'userGrade': instance.userGrade,
      'userClass': instance.userClass,
      'allergyInfo': instance.allergyInfo,
      'sectionOrder': instance.sectionOrder,
    };
