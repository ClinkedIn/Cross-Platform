import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'dart:convert';
import 'package:lockedin/features/admin/models/job.dart';

class AdminRepository {
  Future<void> updateUserStatus(String userId, String status) async {
    final response = await RequestService.patch(
      "/admin/user-status",
      body: {"userId": userId, "status": status},
    );
    print('Respocefcefcnse: ${response.body}');
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

  Future<void> updateJobStatus(String jobId, String status) async {
    final bool isActive = status == "active";
    final response = await RequestService.put(
      "/jobs/$jobId",
      body: {"isActive": isActive},
    );
    print('Response: ${response.body}');
    _handleResponse(response);
  }

  Future<void> deleteJob(String jobId) async {
    final response = await RequestService.delete("/admin/jobs/$jobId");
    print('ucybhfeijkcfjv: ${response.body}');
    if (response.statusCode == 200) {
      print('Job deleted successfully');
    } else {
      throw Exception('Failed to delete job: ${response.body}');
    }
  }

  Future<List<Job>> fetchAllJobs() async {
    try {
      final response = await RequestService.get("/jobs");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          final List jobsJson = data;
          print('Jobs count: ${jobsJson.length}');
          return jobsJson
              .map((e) => Job.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          // Handle case where data is not a list
          print('Unexpected data format: $data');
          return [];
        }
      } else {
        throw Exception("Failed to load jobs: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      throw Exception("Failed to load jobs: $e");
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
