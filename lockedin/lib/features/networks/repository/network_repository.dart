import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/request_list_model.dart';

class RequestService {
  
  static const String baseUrl = '10.0.2.2';
  final http.Client _httpClient;
  
  RequestService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  Future<RequestList> getRequests() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/user/connections/request'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

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
    try {
      // Using PATCH with the specified JSON format
      final response = await _httpClient.patch(
        Uri.parse('$baseUrl/requests/$requestId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': action
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update request status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating request status: $e');
    }
  }
}