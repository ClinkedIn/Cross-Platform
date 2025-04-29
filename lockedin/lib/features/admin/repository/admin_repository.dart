import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'dart:convert';

class AdminRepository {
  Future<void> updateUserStatus(String userId, String status) async {
    final response = await RequestService.patch(
      "/admin/user-status",
      body: {"userId": userId, "status": status},
    );
    _handleResponse(response);
  }

  Future<void> updateUserRole(String userId, String role) async {
    final response = await RequestService.patch(
      "/admin/user-role",
      body: {"userId": userId, "role": role},
    );
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final response = await RequestService.get("/admin/analytics/overview");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, dynamic>.from(data["data"]);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      print('Success: ${response.body}');
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }
}
