import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/notifiers/error_notifier.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/l10n/app_localizations.dart';

class UserDataService {
  final AuthService _authService = locator<AuthService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  void trySetPreferredPreferences(BuildContext context, {required UserDataModel userData}) {
    final userPreferences = userData.preferences;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    localeProvider.setLocale(userPreferences.locale);
    themeProvider.setTheme(userPreferences.theme);
  }

  Future<UserPreferencesModel?> updatePreferences(BuildContext context, UserPreferencesModel preferences) async {
    final response = await _authService.authenticatedRequest(
      method: 'PATCH',
      endpoint: 'users/me/',
      body: jsonEncode({
        'preferences': preferences.toJson(),
      }),
    );

    if (response != null && response.statusCode == 200) {
      return UserPreferencesModel.fromJson(jsonDecode(response.body)['preferences']);
    } else {
      ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToUpdateUserSettings);
      return null;
    }
  }

  Future<UserDataModel?> updateUserData(BuildContext context, UserDataModel userData) async {
    final response = await _authService.authenticatedRequest(
      method: 'PATCH',
      endpoint: 'users/me/',
      body: jsonEncode(userData.toJson()),
    );

    if (response != null && response.statusCode == 200) {
      final userData = UserDataModel.fromJson(jsonDecode(response.body));
      await _localStorageService.saveUserData(userData);
      return userData;
    } else {
      ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToUpdateUserData);
      return null;
    }
  }
}
