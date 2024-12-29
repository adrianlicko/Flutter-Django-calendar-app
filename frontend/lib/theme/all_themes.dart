import 'package:flutter/material.dart';

enum AllAppColors {
  lightBlueColorScheme(
    primaryColor: Color.fromRGBO(0, 121, 191, 1),
    primaryColorDark: Color.fromRGBO(4, 82, 145, 1),
    primaryColorLight: Color.fromRGBO(197, 232, 250, 1),
    secondaryColor: Color.fromRGBO(255, 255, 255, 1),
    scaffoldBackgroundColor: Color(0xFFF6F1F1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.black,
    iconColor: Colors.white,
    appbarIconColor: Colors.black,
  ),
  darkBlueColorScheme(
    primaryColor: Color.fromRGBO(0, 121, 191, 1),
    primaryColorDark: Color.fromRGBO(4, 82, 145, 1),
    primaryColorLight: Color.fromRGBO(197, 232, 250, 1),
    secondaryColor: Color.fromRGBO(45, 45, 45, 1),
    scaffoldBackgroundColor: Color.fromRGBO(35, 35, 35, 1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.white,
    iconColor: Colors.black,
    appbarIconColor: Colors.white,
  ),
  darkRedColorScheme(
    primaryColor: Color.fromRGBO(162, 29, 19, 1),
    primaryColorDark: Color.fromRGBO(120, 14, 14, 1),
    primaryColorLight: Color.fromRGBO(255, 199, 196, 1),
    secondaryColor: Color.fromRGBO(45, 45, 45, 1),
    scaffoldBackgroundColor: Color.fromRGBO(35, 35, 35, 1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.white,
    iconColor: Colors.black,
    appbarIconColor: Colors.white,
  ),
  darkGreenColorScheme(
    primaryColor: Color.fromRGBO(33, 163, 0, 1),
    primaryColorDark: Color.fromRGBO(38, 145, 4, 1),
    primaryColorLight: Color.fromRGBO(207, 250, 197, 1),
    secondaryColor: Color.fromRGBO(45, 45, 45, 1),
    scaffoldBackgroundColor: Color.fromRGBO(35, 35, 35, 1),
    titleColor: Color.fromRGBO(200, 200, 200, 1),
    textColor: Colors.white,
    iconColor: Colors.black,
    appbarIconColor: Colors.white,
  );

  final Color primaryColor;
  final Color primaryColorDark;
  final Color primaryColorLight;
  final Color secondaryColor;
  final Color scaffoldBackgroundColor;
  final Color titleColor;
  final Color textColor;
  final Color iconColor;
  final Color appbarIconColor;

  const AllAppColors({
    required this.primaryColor,
    required this.primaryColorDark,
    required this.primaryColorLight,
    required this.secondaryColor,
    required this.scaffoldBackgroundColor,
    required this.titleColor,
    required this.textColor,
    required this.iconColor,
    required this.appbarIconColor,
  });
}
