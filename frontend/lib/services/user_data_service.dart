import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserDataService {
  final AuthService _authService = locator<AuthService>();
  final String _baseUrl = 'http://127.0.0.1:8000/api/users/me/';

  void trySetPreferredPreferences(BuildContext context, {required UserDataModel userData}) {
    final userPreferences = userData.preferences;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    localeProvider.setLocale(userPreferences.locale);
    themeProvider.setTheme(userPreferences.theme);
  }

  Future<UserPreferencesModel?> updatePreferences(UserPreferencesModel preferences) async {
    final response = await http.patch(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.accessToken}',
      },
      body: jsonEncode({
        'preferences': preferences.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return UserPreferencesModel.fromJson(jsonDecode(response.body)['preferences']);
    } else {
      return null;
    }
  }

  Future<UserDataModel?> updateUserData(UserDataModel userData) async {
    final response = await http.patch(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authService.accessToken}',
      },
      body: jsonEncode(userData.toJson())
    );

    if (response.statusCode == 200) {
      return UserDataModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }
}
