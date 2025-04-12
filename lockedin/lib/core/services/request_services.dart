import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';

class RequestService {
  static final String _baseUrl = Constants.baseUrl;
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

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParameters);

    final headers = await _getHeaders(additionalHeaders: additionalHeaders);
    debugPrint('GET Request: ${uri.toString()}');

    try {
      final response = await _client.get(uri, headers: headers);
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      debugPrint('GET request failed: $e');
      throw Exception('GET request failed: $e');
    }
  }

  /// Generic POST request with body and optional headers
  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final String url = '$_baseUrl$endpoint';
      final Uri uri = Uri.parse(url);
      final headers = await _getHeaders(additionalHeaders: additionalHeaders);

      // Debug information
      debugPrint('POST Request URL: $url');
      debugPrint('POST Request Headers: $headers');
      final jsonBody = jsonEncode(body);
      debugPrint('POST Request Body: $jsonBody');

      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonBody,
      );
      
      // Debug response information
      debugPrint('POST Response Status: ${response.statusCode}');
      debugPrint('POST Response Headers: ${response.headers}');
      
      if (response.body.length < 1000) {
        debugPrint('POST Response Body: ${response.body}');
      } else {
        debugPrint('POST Response Body (truncated): ${response.body.substring(0, 1000)}...');
      }
      
      _storeCookiesFromResponse(response);
      return response;
    } catch (e, stackTrace) {
      debugPrint('POST request failed: $e');
      debugPrint('Stack trace: $stackTrace');
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
    debugPrint('PUT Request: $url');

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      debugPrint('PUT request failed: $e');
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
    debugPrint('DELETE Request: $url');

    try {
      final response = await _client.delete(Uri.parse(url), headers: headers);
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      debugPrint('DELETE request failed: $e');
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Logs in and automatically stores the cookie
  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final String url = '$_baseUrl${Constants.loginEndpoint}';
    debugPrint('LOGIN Request: $url');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      debugPrint('Login request failed: $e');
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
