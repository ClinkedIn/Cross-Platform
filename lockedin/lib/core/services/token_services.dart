import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _cookieKey = 'auth_cookie';

  /// Save cookie securely
  static Future<void> saveCookie(String cookie) async {
    await _storage.write(key: _cookieKey, value: cookie);
  }

  /// Retrieve cookie
  static Future<String?> getCookie() async {
    return await _storage.read(key: _cookieKey);
  }

  /// Remove cookie (Logout)
  static Future<void> deleteCookie() async {
    await _storage.delete(key: _cookieKey);
  }

  /// Check if cookie exists
  static Future<bool> hasCookie() async {
    return await _storage.containsKey(key: _cookieKey);
  }
}
