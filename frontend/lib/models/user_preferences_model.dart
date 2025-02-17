import 'package:flutter/material.dart';
import 'package:frontend/theme/all_themes.dart';

class UserPreferencesModel {
  Locale locale;
  AllAppColors theme;
  bool showTodosInCalendar;
  bool removeTodoFromCalendarWhenCompleted;

  UserPreferencesModel({
    required this.locale,
    required this.theme,
    required this.showTodosInCalendar,
    required this.removeTodoFromCalendarWhenCompleted,
  });

  void setLocale(Locale locale) {
    this.locale = locale;
  }

  void setTheme(AllAppColors theme) {
    this.theme = theme;
  }

  void setShowTodosInCalendar(bool showTodosInCalendar) {
    this.showTodosInCalendar = showTodosInCalendar;
  }

  void setRemoveTodoFromCalendarWhenCompleted(bool removeTodoFromCalendarWhenCompleted) {
    this.removeTodoFromCalendarWhenCompleted = removeTodoFromCalendarWhenCompleted;
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
  return UserPreferencesModel(
    locale: Locale(json['locale'] ?? 'en'),
    theme: AllAppColors.values.firstWhere(
      (e) => e.name == json['theme'],
      orElse: () => AllAppColors.darkRedColorScheme,
    ),
    showTodosInCalendar: json['showTodosInCalendar'] ?? true,
    removeTodoFromCalendarWhenCompleted: json['removeTodoFromCalendarWhenCompleted'] ?? true,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'locale': locale.languageCode,
      'theme': theme.name,
      'showTodosInCalendar': showTodosInCalendar,
      'removeTodoFromCalendarWhenCompleted': removeTodoFromCalendarWhenCompleted,
    };
  }
}