import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupRepository {
  final String _apiUrl =
      'https://b0a78715-5d8e-4e23-bda1-4d800a9e4a0f.mock.pstmn.io/register';

  Future<http.Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    return await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "remember_me": rememberMe,
      }),
    );
  }
}
