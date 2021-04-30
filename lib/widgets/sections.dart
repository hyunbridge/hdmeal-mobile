// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'package:hdmeal/utils/launch.dart';

const _weekday = ["", "월", "화", "수", "목", "금", "토", "일"];
const _allergyString = [
  "",
  "난류",
  "우유",
  "메밀",
  "땅콩",
  "대두",
  "밀",
  "고등어",
  "게",
  "새우",
  "돼지고기",
  "복숭아",
  "토마토",
  "아황산류",
  "호두",
  "닭고기",
  "쇠고기",
  "오징어",
  "조개류"
];

List<Widget> menuSection(
    {BuildContext context, DateTime date, List menu, bool showAllergyInfo}) {
  if (menu.length == 0) {
    return [
      ListTile(
        title: Text(
          "급식",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTile(
        title: Text("식단정보가 없습니다."),
        visualDensity: VisualDensity(vertical: -4),
      ),
    ];
  }

  final shareText =
      "<${date.month}월 ${date.day}일(${_weekday[date.weekday]})>\n${menu.map((e) => e[0]).join(",\n")}";

  final section = <Widget>[
    ListTile(
      title: Text(
        "급식",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Transform.translate(
        offset: Offset(16, 0),
        child: Visibility(
          child: IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(shareText);
              }),
          visible: !kIsWeb,
        ),
      ),
    ),
  ];

  menu.forEach((element) {
    if (element[1].length == 0 || !showAllergyInfo) {
      section.add(ListTile(
        title: Text(element[0]),
        visualDensity: VisualDensity(vertical: -4),
        onTap: () async {
          launch(context,
              "https://www.google.com/search?q=${Uri.encodeComponent(element[0])}&tbm=isch");
        },
      ));
    } else {
      final String allergyInfo =
          element[1].map((n) => _allergyString[n]).join(", ");
      section.add(ListTile(
        title: Text(element[0]),
        subtitle: Text(
          allergyInfo,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        visualDensity: VisualDensity(vertical: -4),
        onTap: () async {
          launch(context,
              "https://www.google.com/search?q=${Uri.encodeComponent(element[0])}&tbm=isch");
        },
      ));
    }
  });

  return section;
}

List<Widget> timetableSection(
    {BuildContext context,
    int userGrade,
    int userClass,
    List timetable,
    void Function() onTap}) {
  if (timetable.length == 0) {
    timetable.add("시간표 정보가 없습니다.");
  }

  return [
    ListTile(
      title: Text(
        "$userGrade학년 $userClass반 시간표",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    ),
    ...timetable.map((e) => ListTile(
          title: Text(e),
          visualDensity: VisualDensity(vertical: -4),
        ))
  ];
}

List<Widget> scheduleSection(
    {BuildContext context,
    int userGrade,
    List schedule,
    bool showMyScheduleOnly}) {
  final section = <Widget>[
    ListTile(
      title: Text(
        "학사일정",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];

  if (schedule.length == 0) {
    section.add(ListTile(
      title: Text("학사일정이 없습니다."),
      visualDensity: VisualDensity(vertical: -4),
    ));
  } else {
    schedule.forEach((element) {
      if (showMyScheduleOnly) {
        if (element[1].length == 0 || element[1].contains(userGrade)) {
          section.add(ListTile(
            title: Text(element[0]),
            visualDensity: VisualDensity(vertical: -4),
          ));
        }
      } else {
        String _relatedGrade;
        if (element[1].length == 0) {
          _relatedGrade = '';
        } else {
          _relatedGrade = '(${element[1].join("학년, ")}학년)';
        }
        section.add(ListTile(
          title: Text(element[0] + _relatedGrade),
          visualDensity: VisualDensity(vertical: -4),
        ));
      }
    });
  }

  return section;
}
