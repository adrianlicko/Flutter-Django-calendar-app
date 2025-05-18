import 'package:frontend/models/user_preferences_model.dart';

class UserDataModel {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final UserPreferencesModel preferences;
  final String? password;

  UserDataModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.preferences,
    this.password,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] as int?,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String? ?? '',
      preferences: UserPreferencesModel.fromJson(json['preferences'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      if (id != null) 'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'preferences': preferences.toJson(),
    };
    return data;
  }
}