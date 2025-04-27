import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:http_parser/http_parser.dart';

class RequestService {
  static final String _baseUrl = Constants.baseUrl;
  static http.Client _client = http.Client();

  static void setClient(http.Client client) {
    _client = client;
  }

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

  static Future<http.Response> postMultipart(
    String endpoint, {
    File? file,
    String fileFieldName = 'file',
    Map<String, dynamic>? additionalFields,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final String? storedCookie = await TokenService.getCookie();

    var request = http.MultipartRequest('POST', uri);

    // Add file if present
    if (file != null) {
      // Determine file extension and content type
      final String path = file.path;
      final String extension = path.split('.').last.toLowerCase();

      // Set appropriate content type based on file extension
      MediaType contentType;
      switch (extension) {
        case 'pdf':
          contentType = MediaType('application', 'pdf');
          break;
        case 'doc':
          contentType = MediaType('application', 'msword');
          break;
        case 'docx':
          contentType = MediaType(
            'application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document',
          );
          break;
        case 'xls':
          contentType = MediaType('application', 'vnd.ms-excel');
          break;
        case 'xlsx':
          contentType = MediaType(
            'application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
          break;
        case 'ppt':
          contentType = MediaType('application', 'vnd.ms-powerpoint');
          break;
        case 'pptx':
          contentType = MediaType(
            'application',
            'vnd.openxmlformats-officedocument.presentationml.presentation',
          );
          break;
        case 'txt':
          contentType = MediaType('text', 'plain');
          break;
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        default:
          contentType = MediaType('application', 'octet-stream');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: contentType,
        ),
      );
    }

    // Add regular fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value;
        } else {
          request.fields[key] = jsonEncode(value);
        }
      });
    }

    // Add cookie if available
    if (storedCookie != null && storedCookie.isNotEmpty) {
      request.headers['Cookie'] = storedCookie;
    }

    // Add additional headers if provided
    if (headers != null) {
      request.headers.addAll(headers);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _storeCookiesFromResponse(response);
      return response;
    } catch (e) {
      throw Exception('Multipart POST failed: $e');
    }
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    Map<String, String>? queryParameters,
    int retryCount = 0,
  }) async {
    // Ensure the endpoint starts with '/'
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }

    final Uri uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParameters);

    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 401) {
        TokenService.deleteCookie();
      }
      return response;
    } catch (e) {
      // Retry network errors as well
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 1));
        return get(
          endpoint,
          additionalHeaders: additionalHeaders,
          queryParameters: queryParameters,
          retryCount: retryCount + 1,
        );
      }

      throw Exception('GET request failed: $e');
    }
  }

  /// Generic POST request with body and optional headers
  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
    int retryCount = 0,
  }) async {
    try {
      // Ensure the endpoint starts with '/'
      if (!endpoint.startsWith('/')) {
        endpoint = '/$endpoint';
      }

      final String url = '$_baseUrl$endpoint';
      final Uri uri = Uri.parse(url);
      final headers = await _getHeaders(additionalHeaders: additionalHeaders);

      final jsonBody = jsonEncode(body);

      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonBody,
      );

      // Check if we got HTML instead of JSON
      if (_isHtmlResponse(response)) {
        // Retry logic for HTML responses (max 2 retries)
        if (retryCount < 2) {
          // Refresh the authentication token if we have one
          await TokenService.getCookie(); // Ensure we have latest token
          // Wait a bit before retrying
          await Future.delayed(Duration(seconds: 1));
          // Retry the request with incremented retry count
          return post(
            endpoint,
            body: body,
            additionalHeaders: additionalHeaders,
            retryCount: retryCount + 1,
          );
        }
      }

      if (response.body.length < 1000) {
        debugPrint('POST Response Body: ${response.body}');
      } else {
        debugPrint(
          'POST Response Body (truncated): ${response.body.substring(0, 1000)}...',
        );
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('POST request failed: $e');
      debugPrint('Stack trace: $stackTrace');

      // Retry network errors as well
      if (retryCount < 2) {
        debugPrint(
          'Retrying failed POST request (attempt ${retryCount + 1})...',
        );
        await Future.delayed(Duration(seconds: 1));
        return post(
          endpoint,
          body: body,
          additionalHeaders: additionalHeaders,
          retryCount: retryCount + 1,
        );
      }

      throw Exception('POST request failed: $e');
    }
  }

  // PATCH request
  static Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
  }) async {
    final String url = '$_baseUrl$endpoint';
    final headers = await _getHeaders(additionalHeaders: additionalHeaders);

    try {
      final response = await _client.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('PATCH request failed: $e');
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
    debugPrint('LOGIN Request Body: $email, $password');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('LOGIN Response: ${response.body}');
      debugPrint('LOGIN Response Headers: ${response.headers}');

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

  /// Check if the response is HTML instead of JSON
  static bool _isHtmlResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final body = response.body;

    return contentType.contains('text/html') ||
        body.contains('<!DOCTYPE html>') ||
        body.contains('<html>') ||
        (body.isNotEmpty && !body.startsWith('{') && !body.startsWith('['));
  }
}
