import 'package:flutter/material.dart';
import 'package:frontend/theme/all_themes.dart';

class UserPreferencesModel {
  final Locale locale;
  final AllAppColors theme;
  final bool showTodosInCalendar;
  final bool removeTodoFromCalendarWhenCompleted;

  UserPreferencesModel({
    required this.locale,
    required this.theme,
    required this.showTodosInCalendar,
    required this.removeTodoFromCalendarWhenCompleted,
  });

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