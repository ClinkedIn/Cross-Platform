import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/profile/model/other_profile_model.dart';
import 'package:lockedin/features/profile/model/user_model.dart'; // Where your HTTP logic is
import 'dart:convert';

class OtherProfileRepository {
  Future<OtherProfileData> getUserProfile(String userId) async {
    print("Fetching user data for  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️ : $userId");
    final response = await RequestService.get("/user/$userId");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("User data:📀📀 $data");

      final user = UserModel.fromJson(data['user']);
      final canSendConnectionRequest =
          data['canSendConnectionRequest'] ?? false;

      return OtherProfileData(
        user: user,
        canSendConnectionRequest: canSendConnectionRequest,
      );
    } else {
      print("Error fetching user data:📀📀 ${response.body}");
      throw Exception("Failed to fetch user data: ${response.body}");
    }
  }

  Future<String> getUserConnectionStatus(String userId) async {
    final response = await RequestService.get("/user/connections/$userId");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] ?? "none";
    } else {
      print("Error fetching connection status: ${response.body}");
      throw Exception("Failed to fetch connection status: ${response.body}");
    }
  }

  Future<bool> sendConnectionRequest(String userId) async {
    final response = await RequestService.post(
      "/user/connections/request/$userId",
      body: {},
    );
    if (response.statusCode == 200) {
      print("Connection request sent successfully.");
      return true;
    } else {
      print("Error sending connection request: ${response.body}");
      return false;
    }
  }

  Future<bool> sendFollowRequest(String userId) async {
    final response = await RequestService.post(
      "/user/follow/$userId",
      body: {},
    );
    if (response.statusCode == 200) {
      print("Connection request sent successfully.");
      return true;
    } else {
      print("Error sending connection request: ${response.body}");
      return false;
    }
  }

  Future<bool> unConnectUser(String userId) async {
    final response = await RequestService.delete("/user/connections/$userId");
    if (response.statusCode == 200) {
      print("User unconnected successfully.");
      return true;
    } else {
      print("Error unconnecting user: ${response.body}");
      return false;
    }
  }

  Future<bool> handleConnectionRequest(String userId, String action) async {
    final response = await RequestService.patch(
      "/user/connections/requests/$userId",
      body: {"action": action},
    );

    if (response.statusCode == 200) {
      print("Connection request ${action}d successfully.");
      return true;
    } else {
      print("Error ${action}ing connection request: ${response.body}");
      return false;
    }
  }

  Future<void> cancelConnectionRequest(String userId) async {
    final response = await RequestService.delete("/user/connect/$userId");

    if (response.statusCode == 200) {
      print("Connection request canceled successfully.");
    } else {
      print("Error canceling connection request: ${response.body}");
      throw Exception("Failed to cancel connection request: ${response.body}");
    }
  }
}
