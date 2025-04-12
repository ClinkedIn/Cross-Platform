import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/profile/model/position_model.dart';

class PositionService {
  // Add position to user profile
  static Future<http.Response> addPosition(Position position) async {
    try {
      // Convert the position object to JSON string for logging
      final jsonString = jsonEncode(position.toJson());
      print("Adding experience: ${position.toJson()}");
      print("Sending to API: $jsonString");

      final response = await RequestService.post(
        "/user/experience", // Changed endpoint to match API
        body: position.toJson(),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      return response;
    } catch (e) {
      print("Exception in addPosition: $e");
      throw Exception("Error adding experience: $e");
    }
  }

  // Upload media file and get URL
  static Future<String?> uploadMediaFile(File file) async {
    try {
      final response = await RequestService.postMultipart(
        "/user/experience/media", // Updated endpoint
        file: file,
      );

      print("Media upload response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Parse the response to get the media URL
          final Map<String, dynamic> responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
          return responseData['url']
              as String?; // May need to update based on API response
        } catch (e) {
          print("Failed to parse media response: $e");
          return null;
        }
      } else {
        throw Exception("Failed to upload media: ${response.body}");
      }
    } catch (e) {
      print("Exception in uploadMediaFile: $e");
      throw Exception("Error uploading media: $e");
    }
  }
}
