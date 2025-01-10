import 'package:frontend/models/user_preferences_model.dart';

class UserDataModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final UserPreferencesModel preferences;
  final String? password;

  UserDataModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.preferences,
    this.password,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      preferences: UserPreferencesModel.fromJson(json['preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'preferences': preferences.toJson(),
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }
}