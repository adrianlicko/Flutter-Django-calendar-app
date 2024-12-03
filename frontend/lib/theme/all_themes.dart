import 'package:flutter/material.dart';

enum AllAppColors {
  lightBlueColorScheme(
    primaryColor: Color.fromRGBO(0, 121, 191, 1),
    primaryAccent: Color.fromRGBO(4, 82, 145, 1),
    secondaryColor: Color.fromRGBO(255, 255, 255, 1),
    secondaryAccent: Color(0xFFF6F1F1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.black,
    iconColor: Colors.white,
    appbarIconColor: Colors.black,
  ),
  darkBlueColorScheme(
    primaryColor: Color.fromRGBO(0, 121, 191, 1),
    primaryAccent: Color.fromRGBO(4, 82, 145, 1),
    secondaryColor: Color.fromRGBO(45, 45, 45, 1),
    secondaryAccent: Color.fromRGBO(35, 35, 35, 1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.white,
    iconColor: Colors.black,
    appbarIconColor: Colors.white,
  ),
  darkRedColorScheme(
    primaryColor: Color.fromRGBO(162, 29, 19, 1),
    primaryAccent: Color.fromRGBO(120, 14, 14, 1),
    secondaryColor: Color.fromRGBO(45, 45, 45, 1),
    secondaryAccent: Color.fromRGBO(35, 35, 35, 1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.white,
    iconColor: Colors.black,
    appbarIconColor: Colors.white,
  );

  final Color primaryColor;
  final Color primaryAccent;
  final Color secondaryColor;
  final Color secondaryAccent;
  final Color titleColor;
  final Color textColor;
  final Color iconColor;
  final Color appbarIconColor;

  const AllAppColors({
    required this.primaryColor,
    required this.primaryAccent,
    required this.secondaryColor,
    required this.secondaryAccent,
    required this.titleColor,
    required this.textColor,
    required this.iconColor,
    required this.appbarIconColor,
  });

  Color get getPrimaryColor => primaryColor;
  Color get getPrimaryAccent => primaryAccent;
  Color get getSecondaryColor => secondaryColor;
  Color get getSecondaryAccent => secondaryAccent;
  Color get getTitleColor => titleColor;
  Color get getTextColor => textColor;
  Color get getIconColor => iconColor;
  Color get getAppbarIconColor => appbarIconColor;
}