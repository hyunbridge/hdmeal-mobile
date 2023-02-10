// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prefs _$PrefsFromJson(Map<String, dynamic> json) => Prefs(
      allergyInfo: json['allergyInfo'] as bool? ?? true,
      enableBlackTheme: json['enableBlackTheme'] as bool? ?? false,
      enableDataSaver: json['enableDataSaver'] as bool? ?? false,
      enableKeywordHighlight: json['enableKeywordHighlight'] as bool? ?? true,
      highlightedKeywords: (json['highlightedKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            "까스",
            "깐풍기",
            "꼬치",
            "꿀떡",
            "꿔바로우",
            "도넛",
            "떡갈비",
            "떡꼬치",
            "떡볶이",
            "마요",
            "마카롱",
            "맛탕",
            "망고",
            "메론",
            "미트볼",
            "바나나",
            "바베큐",
            "부대찌개",
            "불고기",
            "브라우니",
            "브라운",
            "브레드",
            "브리또",
            "비엔나",
            "빵",
            "새우가스",
            "샌드위치",
            "샐러드",
            "샤브샤브",
            "소세지",
            "송편",
            "스테이크",
            "스파게티",
            "스팸",
            "스프",
            "아이스",
            "에이드",
            "와플",
            "요거트",
            "요구르트",
            "우동",
            "인절미",
            "제육",
            "쥬스",
            "짜장",
            "쫄면",
            "차슈",
            "초코",
            "치즈",
            "치킨",
            "카레",
            "케이크",
            "케익",
            "쿠키",
            "쿨피스",
            "타코야끼",
            "탕수육",
            "토스트",
            "튀김",
            "파이",
            "파인애플",
            "피자",
            "하이라이스",
            "함박",
            "핫도그",
            "핫바",
            "햄",
            "햄버거",
            "훈제"
          ],
      sectionOrder: (json['sectionOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["Meal", "Timetable", "Schedule"],
      showMyScheduleOnly: json['showMyScheduleOnly'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'System',
      userClass: json['userClass'] as int? ?? 1,
      userGrade: json['userGrade'] as int? ?? 1,
    );

Map<String, dynamic> _$PrefsToJson(Prefs instance) => <String, dynamic>{
      'allergyInfo': instance.allergyInfo,
      'enableBlackTheme': instance.enableBlackTheme,
      'enableDataSaver': instance.enableDataSaver,
      'enableKeywordHighlight': instance.enableKeywordHighlight,
      'highlightedKeywords': instance.highlightedKeywords,
      'sectionOrder': instance.sectionOrder,
      'showMyScheduleOnly': instance.showMyScheduleOnly,
      'theme': instance.theme,
      'userClass': instance.userClass,
      'userGrade': instance.userGrade,
    };
