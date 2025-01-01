import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api/';

  Future<bool> register(
      {required String email, required String password, required String firstName, required String lastName}) async {
    final response = await http.post(
      Uri.parse('${baseUrl}users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );
    return response.statusCode == 201;
  }

  Future<String?> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('${baseUrl}token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access'];
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    // todo implement
  }
}
