import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeSignUpApi {
  final _secureStorage = FlutterSecureStorage();

  Future<bool> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    bool rememberMe,
  ) async {
    print('🛠️ FakeSignUpApi.registerUser() called');

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      print('✅ Fake API Success');

      if (rememberMe) {
        await _secureStorage.write(key: 'email', value: email);
        await _secureStorage.write(key: 'password', value: password);
        print('🔐 Credentials saved securely!');
      }

      return true;
    } else {
      print('❌ Fake API Failure');
      return false;
    }
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    String? email = await _secureStorage.read(key: 'email');
    String? password = await _secureStorage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  Future<void> clearSavedCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
    print('🗑️ Secure storage cleared');
  }
}
