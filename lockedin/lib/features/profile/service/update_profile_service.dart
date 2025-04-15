import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class UpdateProfileService {
  static Future<http.Response> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      print("Updating profile with data: $profileData");
      print("Profile data type: ${profileData}");

      final response = await RequestService.patch(
        "/user/profile",
        body: profileData,
      );

      print(
        "Profile update response: ${response.statusCode}, ${response.body}",
      );
      return response;
    } catch (e) {
      print("Error updating profile: $e");
      throw Exception("Failed to update profile: $e");
    }
  }
}
