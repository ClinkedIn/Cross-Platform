import 'dart:convert';

import 'package:lockedin/core/services/request_services.dart';

class BlockedRepository {
  Future<void> blockUser(String userId) async {
    final response = await RequestService.post("/user/block/$userId", body: {});
    if (response.statusCode == 200) {
      print("User blocked successfully.");
    } else {
      print("Error blocking user: ${response.body}");
      throw Exception("Failed to block user: ${response.body}");
    }
  }

  Future<void> unBlockUser(String userId) async {
    final response = await RequestService.delete("/user/block/$userId");
    if (response.statusCode == 200) {
      print("User unblocked successfully.");
    } else {
      print("Error blocking user: ${response.body}");
      throw Exception("Failed to block user: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    final response = await RequestService.get("/user/blocked");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data["blockedUsers"]);
    } else {
      print(
        "Error fetching blocked users: ${response.statusCode} - ${response.body}",
      );
      throw Exception(
        "Failed to fetch blocked users: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
