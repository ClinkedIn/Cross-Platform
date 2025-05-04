import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class UpdateProfileRepository {
  Future<void> updateBasicInfo(Map<String, dynamic> data) async {
    print("Basic info data: $data");
    final response = await RequestService.patch("/user/profile", body: data);
    print("Basic info response: ${response.body}");
    _handleResponse(response, "basic information");
  }

  Future<void> updateContactInfo(Map<String, dynamic> data) async {
    final response = await RequestService.patch(
      "/user/contact-info",
      body: data,
    );
    print("Contact info response: ${response.body}");
    _handleResponse(response, "contact information");
  }

  Future<void> updateAboutInfo(Map<String, dynamic> data) async {
    final response = await RequestService.patch("/user/about", body: data);
    print("Contact info response: ${response.body}");
    _handleResponse(response, "about information");
  }

  Future<void> updatePrivacySettings(String newSettings) async {
    final response = await RequestService.patch(
      "/user/privacy-settings",
      body: {"profilePrivacySettings": newSettings},
    );
    print("Contact info response: ${response.body}");
    _handleResponse(response, "privacy settings");
  }

  Future<void> updateConnectionPrivacySettings(String newSettings) async {
    final response = await RequestService.patch(
      "/privacy/connection-request",
      body: {"connectionRequestPrivacySetting": newSettings},
    );
    _handleResponse(response, "connection privacy settings");
  }

  void _handleResponse(http.Response response, String updateType) {
    if (response.statusCode == 200) {
      print('Success updating $updateType: ${response.body}');
    } else {
      Map<String, dynamic> errorData;
      try {
        errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Unknown error';
        throw Exception('Failed to update $updateType: $errorMessage');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to update $updateType: ${response.body}');
        }
        rethrow;
      }
    }
  }
}
