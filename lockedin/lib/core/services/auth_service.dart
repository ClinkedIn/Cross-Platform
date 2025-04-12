import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profilePicture: json['profilePicture'],
    );
  }
}

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    return await TokenService.hasCookie();
  }

  // Fetch current user data from the backend
  Future<User?> fetchCurrentUser() async {
    try {
      if (!await isLoggedIn()) {
        return null;
      }

      final response = await RequestService.get(Constants.getUserDataEndpoint);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['user'] != null) {
        _currentUser = User.fromJson(data['user']);
        return _currentUser;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      final response = await RequestService.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        await fetchCurrentUser();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final response = await RequestService.get(Constants.logoutEndpoint);
      
      if (response.statusCode == 200) {
        await TokenService.deleteCookie();
        _currentUser = null;
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }
} 