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

bool _checkKeyword(String text, List<String> keywords) {
  var result = false;
  for (final keyword in keywords) {
    if (text.contains(keyword)) {
      result = true;
      break;
    }
  }
  return result;
}

List<Widget> menuSection({
  required BuildContext context,
  required DateTime date,
  required List menu,
  required bool showAllergyInfo,
  required bool enableKeywordHighlight,
  required List<String> highlightedKeywords,
}) {
  try {
    if (menu.length == 0) {
      throw "식단 정보가 없습니다.";
    }

    return [
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: () {
                  Share.share(
                      "<${date.month}월 ${date.day}일(${_weekday[date.weekday]})>\n${menu.map((e) => e[0]).join(",\n")}");
                }),
            visible: !kIsWeb,
          ),
        ),
      ),
      ...menu.map((e) => ListTile(
            title: Text(
              e[0],
              style: enableKeywordHighlight &&
                      _checkKeyword(e[0], highlightedKeywords)
                  ? TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
            subtitle: e[1].length > 0 && showAllergyInfo
                ? Text(
                    e[1].map((n) => _allergyString[n]).join(", "),
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                : null,
            visualDensity: VisualDensity(vertical: -4),
            onTap: () async {
              launch(context,
                  "https://www.google.com/search?q=${Uri.encodeComponent(e[0])}&tbm=isch");
            },
          ))
    ];
  } catch (e) {
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
        title: Text(menu.length == 0 ? "식단 정보가 없습니다." : "식단 정보를 불러올 수 없습니다."),
        visualDensity: VisualDensity(vertical: -4),
      ),
    ];
  }
}

List<Widget> timetableSection(
    {required BuildContext context,
    required int userGrade,
    required int userClass,
    required List timetable,
    required void Function() onTap}) {
  final header = ListTile(
    title: Text(
      "$userGrade학년 $userClass반 시간표",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    onTap: onTap,
  );

  try {
    if (timetable.length == 0) {
      throw "시간표 정보가 없습니다.";
    }

    return [
      header,
      ...timetable.map((e) => ListTile(
            title: Text(e),
            visualDensity: VisualDensity(vertical: -4),
          ))
    ];
  } catch (_) {
    return [
      header,
      ListTile(
        title:
            Text(timetable.length == 0 ? "시간표 정보가 없습니다." : "시간표를 불러올 수 없습니다."),
        visualDensity: VisualDensity(vertical: -4),
      )
    ];
  }
}

List<Widget> scheduleSection(
    {required BuildContext context,
    required int userGrade,
    required List schedule,
    required bool showMyScheduleOnly}) {
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

  try {
    schedule.forEach((element) {
      if (showMyScheduleOnly) {
        if (element[1].length == 0 || element[1].contains(userGrade)) {
          section.add(ListTile(
            title: Text(element[0]),
            visualDensity: VisualDensity(vertical: -4),
          ));
        }
      } else {
        section.add(ListTile(
          title: Text(element[0]),
          visualDensity: VisualDensity(vertical: -4),
          subtitle: Text(
            '${element[1].join("학년, ")}학년',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ));
      }
    });

    if (section.length == 1) {
      throw "학사일정이 없습니다.";
    }
  } catch (_) {
    section.add(ListTile(
      title: Text(section.length == 1 ? "학사일정이 없습니다." : "학사일정을 불러올 수 없습니다."),
      visualDensity: VisualDensity(vertical: -4),
    ));
  }

  return section;
}
