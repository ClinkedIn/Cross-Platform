import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class ProfilePhotoService {
  static Future<http.Response> updateProfilePhoto(File photoFile) async {
    try {
      final response = await RequestService.postMultipart(
        "/user/pictures/profile-picture",
        file: photoFile,
      );
      print(
        "Response status couhoef3ede: ${response.statusCode}, boedefrfrdy: ${response.body} type of file: ${photoFile.uri}",
      );
      return response;
    } catch (e) {
      throw Exception("Error updating profile picture: $e");
    }
  }

  static Future<http.Response> deleteProfilePhoto() async {
    try {
      final response = await RequestService.delete(
        "/user/pictures/profile-picture",
      );
      return response;
    } catch (e) {
      throw Exception("Error updating profile picture: $e");
    }
  }
}
