import 'package:flutter/material.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AllAppColors _currentTheme = AllAppColors.lightBlueColorScheme;

  ThemeData get themeData => AppTheme.getThemeFromColors(_currentTheme);

  AllAppColors get currentTheme => _currentTheme;

  void setTheme(AllAppColors theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}