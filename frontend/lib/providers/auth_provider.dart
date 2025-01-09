import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  bool _isLoading = false;

  bool get isAuthenticated => _authService.accessToken != null;
  bool get isLoading => _isLoading;
  String? get accessToken => _authService.accessToken;
  UserDataModel? _user;
  UserDataModel? get user => _user;

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    if (success) {
      success = await login(email: email, password: password);
      _user = await _authService.getCurrentUser();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final tokens = await _authService.login(email: email, password: password);
    if (tokens != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', tokens['access']);
      await prefs.setString('refreshToken', tokens['refresh']);
      _authService.setTokens(access: tokens['access'], refresh: tokens['refresh']);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _user = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('accessToken');
    final refresh = prefs.getString('refreshToken');

    if (access != null && refresh != null) {
      _authService.setTokens(access: access, refresh: refresh);
      _user = await _authService.getCurrentUser();

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> refreshToken() async {
    final success = await _authService.refreshAccessToken();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _authService.accessToken!);
      notifyListeners();
      return true;
    }
    await logout();
    return false;
  }
}