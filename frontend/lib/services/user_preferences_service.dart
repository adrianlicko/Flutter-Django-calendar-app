import 'dart:convert';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class UserPreferencesService {
  final AuthService _authService = locator<AuthService>();
  final String _baseUrl = 'http://127.0.0.1:8000/api/users/me/';

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
}
