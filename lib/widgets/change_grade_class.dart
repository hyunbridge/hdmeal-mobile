// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

typedef void OnChangedCallback(int selectedGrade, int selectedClass);

class ChangeGradeClass extends StatefulWidget {
  final int currentGrade;
  final int currentClass;
  final OnChangedCallback onChanged;

  ChangeGradeClass({
    @required this.currentGrade,
    @required this.currentClass,
    @required this.onChanged,
  });

  @override
  _ChangeGradeClassState createState() => _ChangeGradeClassState();
}

class _ChangeGradeClassState extends State<ChangeGradeClass> {
  int selectedGrade;
  int selectedClass;

  @override
  void initState() {
    super.initState();
    selectedGrade = widget.currentGrade;
    selectedClass = widget.currentClass;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _themeData = Theme.of(context);
    TextStyle _textStyle = _themeData.textTheme.bodyText2
        .copyWith(fontSize: 24, color: Colors.grey);
    TextStyle _selectedTextStyle = _themeData.textTheme.headline5
        .copyWith(fontSize: 24, color: _themeData.textTheme.bodyText1.color);
    return AlertDialog(
      title: Text("학년/반 변경"),
      content: Transform.translate(
        offset: const Offset(-15, 0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Stack(
            children: [
              Transform.translate(
                offset: const Offset(50, 45),
                child: Text(
                  '학년',
                  style: _selectedTextStyle,
                ),
              ),
              NumberPicker(
                value: selectedGrade,
                minValue: 1,
                maxValue: 3,
                onChanged: (newValue) {
                  setState(() => selectedGrade = newValue);
                  widget.onChanged(selectedGrade, selectedClass);
                },
                textStyle: _textStyle,
                selectedTextStyle: _selectedTextStyle,
                itemWidth: 80,
                itemHeight: 40,
              ),
            ],
          ),
          Stack(
            children: [
              Transform.translate(
                offset: const Offset(50, 45),
                child: Text(
                  '반',
                  style: _selectedTextStyle,
                ),
              ),
              NumberPicker(
                value: selectedClass,
                minValue: 1,
                maxValue: 9,
                onChanged: (newValue) {
                  setState(() => selectedClass = newValue);
                  widget.onChanged(selectedGrade, selectedClass);
                },
                textStyle: _textStyle,
                selectedTextStyle: _selectedTextStyle,
                itemWidth: 80,
                itemHeight: 40,
              ),
            ],
          ),
        ]),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("닫기"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
