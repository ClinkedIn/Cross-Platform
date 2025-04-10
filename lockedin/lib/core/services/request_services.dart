import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';

class RequestService {
  static const String _baseUrl = Constants.baseUrl;
  static final http.Client _client = http.Client();

  /// Prepares request headers, including stored cookies if available.
  static Future<Map<String, String>> _getHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final String? storedCookie = await TokenService.getCookie();

    return {
      'Content-Type': 'application/json',
      if (storedCookie != null && storedCookie.isNotEmpty)
        'Cookie': storedCookie,
      ...?additionalHeaders,
    };
  }

  /// Generic GET request with optional headers
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await _client.get(Uri.parse(url), headers: headers);
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// Generic POST request with body and optional headers
  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// PUT request
  static Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await _client.delete(Uri.parse(url), headers: headers);
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Logs in and automatically stores the cookie
  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final String url = '$_baseUrl${Constants.loginEndpoint}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      throw Exception('Login request failed: $e');
    }
  }

  /// Parses and stores cookies from a response
  static void _storeCookiesFromResponse(http.Response response) {
    final rawSetCookie = response.headers['set-cookie'];
    if (rawSetCookie != null) {
      final cleanedCookies = rawSetCookie
          .split(',')
          .map((cookie) => cookie.split(';').first.trim())
          .join('; ');
      TokenService.saveCookie(cleanedCookies);
    }
  }
}
