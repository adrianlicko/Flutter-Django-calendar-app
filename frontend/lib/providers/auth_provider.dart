import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

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

    String? token = await _authService.login(email: email, password: password);
    if (token != null) {
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return false;
    }
    _token = prefs.getString('authToken');
    notifyListeners();
    return true;
  }
}