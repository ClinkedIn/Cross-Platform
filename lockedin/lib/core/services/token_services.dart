import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Create storage with specific options
  static const _storage = FlutterSecureStorage(
    // Optional: You can add platform-specific configurations here if needed
    // iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    // aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _cookieKey = 'auth_cookie';

  /// Save cookie securely
  static Future<bool> saveCookie(String cookie) async {
    try {
      await _storage.write(key: _cookieKey, value: cookie);
      return true;
    } catch (e) {
      print('❌ Error saving cookie: $e');
      return false;
    }
  }

  /// Retrieve cookie
  static Future<String?> getCookie() async {
    try {
      return await _storage.read(key: _cookieKey);
    } catch (e) {
      print('❌ Error retrieving cookie: $e');
      return null;
    }
  }

  /// Remove cookie (Logout)
  static Future<bool> deleteCookie() async {
    try {
      await _storage.delete(key: _cookieKey);
      return true;
    } catch (e) {
      print('❌ Error deleting cookie: $e');
      return false;
    }
  }

  /// Check if cookie exists
  static Future<bool> hasCookie() async {
    try {
      return await _storage.containsKey(key: _cookieKey);
    } catch (e) {
      print('❌ Error checking for cookie: $e');
      return false;
    }
  }

  /// Delete all stored keys (full logout)
  static Future<bool> clearAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      print('❌ Error clearing all keys: $e');
      return false;
    }
  }
}
