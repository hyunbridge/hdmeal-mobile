// ██╗  ██╗██████╗ ███╗   ███╗███████╗ █████╗ ██╗
// ██║  ██║██╔══██╗████╗ ████║██╔════╝██╔══██╗██║
// ███████║██║  ██║██╔████╔██║█████╗  ███████║██║
// ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  ██╔══██║██║
// ██║  ██║██████╔╝██║ ╚═╝ ██║███████╗██║  ██║███████╗
// ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝
// Copyright 2020, Hyungyo Seo

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
}
