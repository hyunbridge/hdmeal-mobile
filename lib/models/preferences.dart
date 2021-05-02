// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

@JsonSerializable(nullable: false)
class Prefs {
  bool allergyInfo;
  bool enableBlackTheme;
  bool enableDataSaver;
  bool enableKeywordHighlight;
  List<String> highlightedKeywords;
  List<String> sectionOrder;
  bool showMyScheduleOnly;
  String theme;
  int userClass;
  int userGrade;

  Prefs(
    this.allergyInfo,
    this.enableBlackTheme,
    this.enableDataSaver,
    this.enableKeywordHighlight,
    this.highlightedKeywords,
    this.sectionOrder,
    this.showMyScheduleOnly,
    this.theme,
    this.userClass,
    this.userGrade,
  );
  Prefs.defaultValue() {
    allergyInfo = true;
    enableBlackTheme = false;
    enableDataSaver = false;
    enableKeywordHighlight = true;
    highlightedKeywords = [
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
    ];
    sectionOrder = ["Meal", "Timetable", "Schedule"];
    showMyScheduleOnly = true;
    theme = 'System';
    userClass = 1;
    userGrade = 1;
  }

  factory Prefs.fromJson(Map<String, dynamic> json) => _$PrefsFromJson(json);

  Map<String, dynamic> toJson() => _$PrefsToJson(this);
}
