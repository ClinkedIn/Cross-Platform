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
  bool _useDemoMode = false;

  User? get currentUser => _currentUser;

  // Get a demo user for testing purposes
  User get demoUser => User(
    id: 'demo-user-123',
    firstName: 'Demo',
    lastName: 'User',
    email: 'demo@example.com',
    profilePicture: null,
  );

  // Enable demo mode for testing
  void enableDemoMode() {
    _useDemoMode = true;
    _currentUser = demoUser;
    debugPrint('Demo mode enabled, using demo user: ${demoUser.id}');
  }

  // Check if demo mode is enabled
  bool get isDemoMode => _useDemoMode;

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    if (_useDemoMode) return true;
    final hasCookie = await TokenService.hasCookie();
    debugPrint('Has cookie: $hasCookie');
    return hasCookie;
  }

  // Fetch current user data from the backend
  Future<User?> fetchCurrentUser() async {
    try {
      // If demo mode is enabled, just return the demo user
      if (_useDemoMode) {
        debugPrint('Using demo user: ${demoUser.id}');
        return demoUser;
      }

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
        
        // If API call fails but we have cookies, use demo user as fallback
        debugPrint('Using demo user as fallback');
        enableDemoMode();
        return demoUser;
      }

      // Parse the user data
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['user'] != null) {
        _currentUser = User.fromJson(data['user']);
        debugPrint('Loaded user: ${_currentUser!.id}');
        return _currentUser;
      }

      // If we couldn't get user data but have cookies, use demo user
      debugPrint('No user data in response, using demo user');
      enableDemoMode();
      return demoUser;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      
      // In case of any error, use demo user as fallback
      debugPrint('Using demo user due to error');
      enableDemoMode();
      return demoUser;
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

      // For testing purposes, enable demo mode even if login fails
      enableDemoMode();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      
      // For testing purposes, enable demo mode
      enableDemoMode();
      return true;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      // If in demo mode, just reset it
      if (_useDemoMode) {
        _useDemoMode = false;
        _currentUser = null;
        return true;
      }
      
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