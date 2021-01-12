// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright Hyungyo Seo

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
              NumberPicker.integer(
                initialValue: widget.selectedGrade,
                minValue: 1,
                maxValue: 3,
                onChanged: (newValue) =>
                    setState(() => widget.selectedGrade = newValue),
                textStyle: _textStyle,
                selectedTextStyle: _selectedTextStyle,
                listViewWidth: 80,
                itemExtent: 40,
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
              NumberPicker.integer(
                initialValue: widget.selectedClass,
                minValue: 1,
                maxValue: 9,
                onChanged: (newValue) =>
                    setState(() => widget.selectedClass = newValue),
                textStyle: _textStyle,
                selectedTextStyle: _selectedTextStyle,
                listViewWidth: 80,
                itemExtent: 40,
              ),
            ],
          ),
        ]),
      ),
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
