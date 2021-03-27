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
  List<String> sectionOrder;
  bool showMyScheduleOnly;
  String theme;
  int userClass;
  int userGrade;

  Prefs(
    this.allergyInfo,
    this.enableBlackTheme,
    this.enableDataSaver,
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
    sectionOrder = ["Meal", "Timetable", "Schedule"];
    showMyScheduleOnly = true;
    theme = 'System';
    userClass = 1;
    userGrade = 1;
  }

  factory Prefs.fromJson(Map<String, dynamic> json) => _$PrefsFromJson(json);

  Map<String, dynamic> toJson() => _$PrefsToJson(this);
}
