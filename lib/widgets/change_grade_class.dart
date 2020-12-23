// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

class ChangeGradeClass extends StatefulWidget {
  final int currentGrade;
  final int currentClass;
  int selectedGrade;
  int selectedClass;

  ChangeGradeClass.dialog({
    @required this.currentGrade,
    @required this.currentClass,
  });

  @override
  _ChangeGradeClassState createState() => _ChangeGradeClassState();
}

class _ChangeGradeClassState extends State<ChangeGradeClass> {
  @override
  void initState() {
    super.initState();
    widget.selectedGrade = widget.currentGrade;
    widget.selectedClass = widget.currentClass;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _themeData = Theme.of(context);
    TextStyle _textStyle =
        _themeData.textTheme.bodyText2.copyWith(color: Colors.grey);
    TextStyle _selectedTextStyle =
        _themeData.textTheme.headline5.copyWith(color: Colors.black);
    return AlertDialog(
      title: Text("학년/반 변경"),
      content:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        NumberPicker.integer(
          initialValue: widget.selectedGrade,
          minValue: 1,
          maxValue: 3,
          onChanged: (newValue) =>
              setState(() => widget.selectedGrade = newValue),
          textStyle: _textStyle,
          selectedTextStyle: _selectedTextStyle,
          listViewWidth: 20,
          itemExtent: 40,
        ),
        Text(
          '학년',
          style: _selectedTextStyle,
        ),
        SizedBox(width: 20),
        NumberPicker.integer(
          initialValue: widget.selectedClass,
          minValue: 1,
          maxValue: 9,
          onChanged: (newValue) =>
              setState(() => widget.selectedClass = newValue),
          textStyle: _textStyle,
          selectedTextStyle: _selectedTextStyle,
          listViewWidth: 20,
          itemExtent: 40,
        ),
        Text(
          '반',
          style: _selectedTextStyle,
        ),
      ]),
      actions: <Widget>[
        FlatButton(
          child: Text("닫기"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
