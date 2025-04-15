import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class CoverPhotoService {
  static Future<http.Response> updateCoverPhoto(File photoFile) async {
    try {
      final response = await RequestService.postMultipart(
        "/user/pictures/cover-picture",
        file: photoFile,
      );
      return response;
    } catch (e) {
      throw Exception("Error updating profile picture: $e");
    }
  }

  static Future<http.Response> deleteCoverPhoto() async {
    try {
      final response = await RequestService.delete(
        "/user/pictures/cover-picture",
      );
      return response;
    } catch (e) {
      throw Exception("Error updating profile picture: $e");
    }
  }
}
