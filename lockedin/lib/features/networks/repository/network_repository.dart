import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/networks/model/connection_model.dart';
import 'package:lockedin/features/networks/model/suggestion_model.dart';
import 'package:lockedin/core/services/request_services.dart';
import '../model/request_list_model.dart';

class RequestListService {
  static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  RequestListService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<RequestList> getRequests() async {
    try {
      final response = await RequestService.get("/user/connections/requests");

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return requestListFromJson(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  Future<void> updateRequestStatus(String requestId, String action) async {
    print('Updating request status for ID: $requestId with action: $action');
    try {
      final body = {"action": action};
      // Using PATCH with the specified JSON format
      final response = await RequestService.patch(
        "/user/connections/requests/$requestId",
        body: body,
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update request status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating request status: $e');
      throw Exception('Error updating request status: $e');
    }
  }
}

class SuggestionService {
  static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  SuggestionService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<SuggestionList> getSuggestions({int limit = 10}) async {
    // API call to get connection suggestions
    try {
      final response = await RequestService.get(
        'user/connections/related-users',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return suggestionListFromJson(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  Future<void> sendConnectionRequest(String userId) async {
    try {
      final body = {"targetUserId": userId};
      // Using PATCH with the specified JSON format
      final response = await RequestService.post(
        "/user/connections/request/$userId",
        body: body,
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send connect request status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error sending connect request status: $e');
      throw Exception('Error sending connect request status: $e');
    }
  }
}

class ConnectionListService {
  static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  ConnectionListService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<ConnectionList> getConnections({int page = 1}) async {
    try {
      final response = await RequestService.get("/user/connections");

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return connectionListFromJson(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      final response = await RequestService.delete(
        'user/connections/$connectionId',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete connection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing connection: $e');
    }
  }
}
