import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
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
