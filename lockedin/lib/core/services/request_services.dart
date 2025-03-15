import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';

class RequestService {
  static const String _baseUrl = Constants.baseUrl;

  /// Fetch the authentication token if available
  static Future<Map<String, String>> _getHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    String? token = await TokenService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };
  }

  /// Perform a GET request
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// Perform a POST request
  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// Perform a PUT request
  static Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// Perform a DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }
}
