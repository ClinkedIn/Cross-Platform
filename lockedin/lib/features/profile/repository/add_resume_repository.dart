import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/request_services.dart';

class ResumeRepository {
  Future<bool> uploadResume(File resumeFile) async {
    try {
      final response = await RequestService.postMultipart(
        "/user/resume",
        file: resumeFile,
        fileFieldName: "resume",
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return ResumeRepository();
});
