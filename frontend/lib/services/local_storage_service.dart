import 'dart:convert';
import 'package:frontend/models/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userDataKey = 'offline_user_data';
  static const String _authTokensKey = 'auth_tokens';

  Future<void> saveUserData(UserDataModel userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData.toJson()));
  }

  Future<UserDataModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userDataKey);
    return jsonString != null ? UserDataModel.fromJson(jsonDecode(jsonString)) : null;
  }

  Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokensKey, jsonEncode({'access': accessToken, 'refresh': refreshToken}));
  }

  Future<Map<String, String>?> getAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_authTokensKey);
    if (jsonString != null) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return {'access': map['access'] as String, 'refresh': map['refresh'] as String};
    }
    return null;
  }

  Future<void> clearAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokensKey);
  }
}
