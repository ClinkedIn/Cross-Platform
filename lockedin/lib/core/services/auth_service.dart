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
    final hasCookie = await TokenService.hasCookie();
    debugPrint('Has cookie: $hasCookie');
    return hasCookie;
  }

  // Fetch current user data from the backend
  Future<User?> fetchCurrentUser() async {
    try {
      // Check if we have auth cookies
      if (!await isLoggedIn()) {
        debugPrint('No auth cookies found, returning null');
        return null;
      }

      // Try to get actual user data from the API
      final response = await RequestService.get(Constants.getUserDataEndpoint);
      debugPrint('User /me response status: ${response.statusCode}');
      
      if (response.body.length < 1000) {
        debugPrint('User /me response body: ${response.body}');
      } else {
        debugPrint('User /me response body (truncated): ${response.body.substring(0, 500)}...');
      }

      if (response.statusCode != 200) {
        debugPrint('Failed to get user data, status: ${response.statusCode}');
        return null;
      }

      // Parse the user data
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Check for success based on the actual API response structure
      if (data['message']?.contains('successfully') == true && data['user'] != null) {
        try {
          _currentUser = User.fromJson(data['user']);
          debugPrint('Loaded user: ${_currentUser!.id}');
          return _currentUser;
        } catch (e) {
          debugPrint('Error parsing user data: $e');
          debugPrint('User data keys: ${data['user'].keys.toList()}');
          return null;
        }
      } else if (data['success'] == true && data['user'] != null) {
        // Original format as backup
        _currentUser = User.fromJson(data['user']);
        debugPrint('Loaded user with original format: ${_currentUser!.id}');
        return _currentUser;
      }

      debugPrint('Failed to parse user data: unexpected format');
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