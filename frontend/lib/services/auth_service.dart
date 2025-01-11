import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000/api/' : 'http://127.0.0.1:8000/api/';
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<UserDataModel?> getCurrentUser() async {
    final response = await authenticatedRequest(
      method: 'GET',
      endpoint: 'users/me/',
    );

    if (response != null && response.statusCode == 200) {
      return UserDataModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final defaultPreferences = UserPreferencesModel(
      locale: const Locale('en'),
      theme: AllAppColors.darkRedColorScheme,
      showTodosInCalendar: true,
      removeTodoFromCalendarWhenCompleted: true,
    );

    final response = await authenticatedRequest(
      method: 'POST',
      endpoint: 'users/',
      body: jsonEncode({
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'preferences': defaultPreferences.toJson(),
      }),
      requireAuth: false,
    );

    return response != null && response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
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

  Future<http.Response?> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool requireAuth = true,
  }) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    Uri url = Uri.parse('$_baseUrl$endpoint');

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(url, headers: requestHeaders, body: body);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: requestHeaders, body: body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }
    } catch (e) {
      print('HTTP Request Error: $e');
      return null;
    }

    if (response.statusCode == 401 && requireAuth) {
      bool refreshed = await refreshAccessToken();
      if (refreshed) {
        requestHeaders['Authorization'] = 'Bearer $_accessToken';
        try {
          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(url, headers: requestHeaders);
              break;
            case 'POST':
              response = await http.post(url, headers: requestHeaders, body: body);
              break;
            case 'PATCH':
              response = await http.patch(url, headers: requestHeaders, body: body);
              break;
            case 'DELETE':
              response = await http.delete(url, headers: requestHeaders);
              break;
            default:
              throw UnsupportedError('Unsupported HTTP method: $method');
          }
        } catch (e) {
          print('HTTP Request Error after refresh: $e');
          return null;
        }

        if (response.statusCode == 401) {
          await logout();
          return null;
        }
        return response;
      } else {
        await logout();
        return null;
      }
    }
    return response;
  }
}
