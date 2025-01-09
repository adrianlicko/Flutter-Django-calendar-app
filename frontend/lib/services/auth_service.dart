import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://127.0.0.1:8000/api/';
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<UserDataModel?> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}users/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return UserDataModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> register(
      {required String email, required String password, required String firstName, required String lastName}) async {
    final defaultPreferences = UserPreferencesModel(
      locale: const Locale('en'),
      theme: AllAppColors.darkRedColorScheme,
      showTodosInCalendar: true,
      removeTodoFromCalendarWhenCompleted: true,
    );

    final response = await http.post(
      Uri.parse('${_baseUrl}users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'preferences': defaultPreferences.toJson(),
      }),
    );

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access'];
      _refreshToken = data['refresh'];
      return data;
    } else {
      return null;
    }
  }

  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('${_baseUrl}token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access'];
      return true;
    } else {
      return false;
    }
  }

  void setTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
