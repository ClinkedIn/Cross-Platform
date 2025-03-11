import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignUpApi {
  Future<bool> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    bool rememberMe,
  ) async {
    if (!(firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty)) {
      return false;
    }

    http.Response response = await createUser(
      firstName,
      lastName,
      email,
      password,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<http.Response> createUser(
    String firstName,
    String lastName,
    String email,
    String password,
  ) {
    return http.post(
      Uri.parse('http://localhost:3000/user/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": sha1.convert(utf8.encode(password)).toString(),
      }),
    );
  }
}

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'firstName': String firstName,
        'lastName': String lastName,
        'email': String email,
        'password': String password,
      } =>
        User(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
        ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}
