import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;

  bool get isAuthenticated => _token != null;

  String? get token => _token;

  Future<bool> register(
      {required String email, required String password, required String firstName, required String lastName}) async {
    bool success =
        await _authService.register(email: email, password: password, firstName: firstName, lastName: lastName);
    notifyListeners();
    login(email: email, password: password);
    return success;
  }

  Future<bool> login({required String email, required String password}) async {
    String? token = await _authService.login(email: email, password: password);
    if (token != null) {
      _token = token;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
