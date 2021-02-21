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
  int userGrade;
  int userClass;
  bool allergyInfo;
  List<String> sectionOrder;
  bool receiveNotifications;
  int notificationsHour;
  int notificationsMinute;
  bool showMyScheduleOnly;
  String theme;
  bool enableBlackTheme;

  Prefs(
    this.userGrade,
    this.userClass,
    this.allergyInfo,
    this.sectionOrder,
    this.receiveNotifications,
    this.notificationsHour,
    this.notificationsMinute,
    this.showMyScheduleOnly,
    this.theme,
    this.enableBlackTheme,
  );
  Prefs.defaultValue() {
    userGrade = 1;
    userClass = 1;
    allergyInfo = true;
    sectionOrder = ["Meal", "Timetable", "Schedule"];
    receiveNotifications = false;
    notificationsHour = 7;
    notificationsMinute = 30;
    showMyScheduleOnly = true;
    theme = 'System';
    enableBlackTheme = false;
  }

  factory Prefs.fromJson(Map<String, dynamic> json) => _$PrefsFromJson(json);

  Map<String, dynamic> toJson() => _$PrefsToJson(this);
}
