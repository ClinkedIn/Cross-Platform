import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lockedin/core/services/request_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/auth/services/secure_storage_service.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
      return LoginViewModel(ref);
    });

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  String errorMessage = '';

  LoginViewModel(this.ref) : super(const AsyncValue.data(null));

  /// Email/Password Login using cookie-based authentication
  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    // Reset previous error message
    errorMessage = '';

    // Validate inputs
    if (email.isEmpty) {
      errorMessage = 'Email cannot be empty';
      state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
      return false;
    }

    if (password.isEmpty) {
      errorMessage = 'Password cannot be empty';
      state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
      return false;
    }

    state = const AsyncValue.loading();
    
    try {
      String? fcmToken;
      try {
        // This is a placeholder - implement FCM token retrieval based on your setup
        final settings = await FirebaseMessaging.instance.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          fcmToken = await FirebaseMessaging.instance.getToken();
        } else {
          debugPrint("Push notification permission not granted");
        }
      } catch (e) {
        debugPrint("Warning: Could not get FCM token: $e");
      }

      debugPrint("📱 FCM Token to send: $fcmToken");
      final response = await RequestService.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      if (response.statusCode == 200) {
        await SecureStorageService().saveCredentials(email, password);
        state = const AsyncValue.data(null);
        return true;
      } else {
        // Parse the error message from the response
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else {
            errorMessage = 'Login failed. Please check your credentials.';
          }
        } catch (_) {
          errorMessage = 'Login failed: ${response.reasonPhrase}';
        }

        state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorMessage =
          e.toString().contains('SocketException')
              ? 'Network error. Please check your connection.'
              : 'Login failed: ${e.toString()}';

      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Get the current error message
  String getErrorMessage() {
    return errorMessage;
  }

  /// Sign in with Google and authenticate with backend
    Future<bool> signInWithGoogle() async {
      state = const AsyncValue.loading();
      errorMessage = '';
      
      try {
        // Initialize GoogleSignIn with scopes
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        
        // Start the Google sign-in flow
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        // Check if user aborted the sign-in
        if (googleUser == null) {
          debugPrint("Sign-in aborted by user");
          state = const AsyncValue.data(null);
          return false;
        }

        // Get authentication details from Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Validate tokens
        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          throw Exception("Google authentication tokens are missing");
        }

        // Create Firebase credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        // Get Firebase ID Token - this is what we'll send to our backend
        final String? firebaseToken = await userCredential.user?.getIdToken();
        
        if (firebaseToken == null) {
          throw Exception("Failed to get Firebase ID token");
        }
        
        debugPrint("🔑 Got Firebase ID token, sending to backend...");
        
        // Send the token to our backend
        final response = await _authenticateWithBackend(firebaseToken);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint("✅ Successfully authenticated with backend");
          state = const AsyncValue.data(null);
          return true;
        } else {
          final Map<String, dynamic> responseData = json.decode(response.body);
          errorMessage = responseData['message'] ?? 'Failed to authenticate with backend';
          debugPrint("❌ Failed to authenticate with backend: $errorMessage");
          state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
          return false;
        }
      } catch (e) {
        errorMessage = 'Google Sign-In error: ${e.toString()}';
        debugPrint("❌ $errorMessage");
        state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
        return false;
      }
    }

  /// Send Firebase token to backend for authentication
    Future<http.Response> _authenticateWithBackend(String firebaseToken) async {
      final String endpoint = '/user/auth/google';
      
      // Get FCM token if available (for push notifications)
      String? fcmToken;
      try {
        // This is a placeholder - implement FCM token retrieval based on your setup
        final settings = await FirebaseMessaging.instance.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          fcmToken = await FirebaseMessaging.instance.getToken();
        } else {
          debugPrint("Push notification permission not granted");
        }
      } catch (e) {
        debugPrint("Warning: Could not get FCM token: $e");
      }
      
      // Prepare request body
      final Map<String, dynamic> body = {};
      if (fcmToken != null) {
        body['fcmToken'] = fcmToken;
      }
      
      // Prepare headers with the Firebase ID token
      final Map<String, String> headers = {
        'Authorization': 'Bearer $firebaseToken',
        'Content-Type': 'application/json',
      };
      
      // Make the request to your backend
      try {
        final response = await http.post(
          Uri.parse('${Constants.baseUrl}$endpoint'),
          headers: headers,
          body: json.encode(body),
        );
        
        // Store cookies from response
        _storeCookiesFromResponse(response);
        
        return response;
      } catch (e) {
        debugPrint("Error sending request to backend: $e");
        throw Exception("Failed to communicate with backend: $e");
      }
    }

    // Add this helper method for cookie handling
    void _storeCookiesFromResponse(http.Response response) {
      final rawSetCookie = response.headers['set-cookie'];
      if (rawSetCookie != null) {
        debugPrint("Received cookies from server, storing...");
        
        final cleanedCookies = rawSetCookie
            .split(',')
            .map((cookie) => cookie.split(';').first.trim())
            .join('; ');
        
        TokenService.saveCookie(cleanedCookies);
        debugPrint("Authentication cookies stored successfully");
      } else {
        debugPrint("No cookies received from server");
      }
}
}
