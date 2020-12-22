// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

@JsonSerializable(nullable: false)
class Prefs {
  int userGrade;
  int userClass;
  bool allergyInfo;
  List<String> sectionOrder;

  Prefs(
    this.userGrade,
    this.userClass,
    this.allergyInfo,
    this.sectionOrder,
  );
  Prefs.defaultValue() {
    userGrade = 1;
    userClass = 1;
    allergyInfo = true;
    sectionOrder = ["Meal", "Timetable", "Schedule"];
  }

  factory Prefs.fromJson(Map<String, dynamic> json) => _$PrefsFromJson(json);

  Map<String, dynamic> toJson() => _$PrefsToJson(this);
}
