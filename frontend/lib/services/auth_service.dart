import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/services/connectivity_service.dart';
import 'package:frontend/services/local_storage_service.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://localhost:8000/api/';
  String? _accessToken;
  String? _refreshToken;

  String get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  final ConnectivityService _connectivityService = locator<ConnectivityService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  Future<UserDataModel?> getCurrentUser() async {
    if (!await _connectivityService.checkConnectivityToBackend()) {
      return _localStorageService.getUserData();
    }

    final response = await authenticatedRequest(
      method: 'GET',
      endpoint: 'users/me/',
    );

    if (response != null && response.statusCode == 200) {
      final userData = UserDataModel.fromJson(jsonDecode(response.body));
      await _localStorageService.saveUserData(userData);
      return userData;
    } else {
      return _localStorageService.getUserData();
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
    if (!await _connectivityService.checkConnectivity()) {
      final tokens = await _localStorageService.getAuthTokens();
      if (tokens != null) {
        _accessToken = tokens['access'];
        _refreshToken = tokens['refresh'];
        return {'access': _accessToken, 'refresh': _refreshToken, 'offline': true};
      }
      return null;
    }

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
      await _localStorageService.saveAuthTokens(_accessToken!, _refreshToken!);
      final user = await getCurrentUser();
      if (user != null) {
        _localStorageService.saveUserData(user);
      }
      return data;
    } else {
      return null;
    }
  }

  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) {
      final tokens = await _localStorageService.getAuthTokens();
      if (tokens != null) {
        _refreshToken = tokens['refresh'];
        _accessToken = tokens['access'];
      } else {
        return false;
      }
    }

    bool isDeviceOnline = await _connectivityService.checkConnectivity();

    if (!isDeviceOnline) {
      return _accessToken != null;
    }

    final response = await http.post(
      Uri.parse('${_baseUrl}token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access'];
      await _localStorageService.saveAuthTokens(_accessToken!, _refreshToken!);
      return true;
    } else {
      await _localStorageService.clearAuthTokens();
      await logout();
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
    await _localStorageService.clearAuthTokens();
  }

  Future<http.Response?> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool requireAuth = true,
  }) async {
    if (requireAuth && _accessToken == null) {
      final tokens = await _localStorageService.getAuthTokens();
      if (tokens != null) {
        _accessToken = tokens['access'];
        _refreshToken = tokens['refresh'];
      } else if (await _connectivityService.checkConnectivity()) {
        return null;
      }
    }

    if (!await _connectivityService.checkConnectivity() && requireAuth) {
      return null;
    }

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
          return null;
        }
      }
    }
    return response;
  }
}
