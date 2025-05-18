import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/connectivity_service.dart';
import 'package:frontend/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ConnectivityService _connectivityService = locator<ConnectivityService>();
  bool _isLoading = false;
  bool _isAuthenticated = false;

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

    final loginData = await _authService.login(email: email, password: password);
    if (loginData != null) {
      _user = await _authService.getCurrentUser();
      _isAuthenticated = _user != null;
    } else {
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final tokens = await _localStorageService.getAuthTokens();
    if (tokens == null) {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }

    _authService.setTokens(access: tokens['access']!, refresh: tokens['refresh']!);

    if (await _connectivityService.checkConnectivityToBackend()) {
      if (await _authService.refreshAccessToken()) {
        _user = await _authService.getCurrentUser();
        _isAuthenticated = _user != null;
      } else {
        _isAuthenticated = false;
        _user = null;
        await _localStorageService.clearAuthTokens();
      }
    } else {
      _user = await _localStorageService.getUserData();
      _isAuthenticated = _user != null;
    }

    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> refreshToken() async {
    final success = await _authService.refreshAccessToken();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _authService.accessToken!);
      _user = await _authService.getCurrentUser();
      notifyListeners();
      return true;
    }
    await logout();
    return false;
  }
}
