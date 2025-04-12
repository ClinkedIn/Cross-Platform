import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/profile/model/education_model.dart';

class EducationService {
  // Add education to user profile
  static Future<http.Response> addEducation(Education education) async {
    try {
      // Convert the education object to JSON string for logging
      final response = await RequestService.post(
        "/user/education",
        body: education.toJson(),
      );
      return response;
    } catch (e) {
      throw Exception("Error adding education: $e");
    }
  }

  // Upload media file and get URL
  static Future<String?> uploadMediaFile(File file) async {
    try {
      final response = await RequestService.postMultipart(
        "/user/education/media",
        file,
      );

      print("Media upload response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Parse the response to get the media URL
          final Map<String, dynamic> responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
          return responseData['mediaUrl'] as String?;
        } catch (e) {
          print("Failed to parse media response: $e");
          // Return the raw response body as fallback
          return response.body;
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
