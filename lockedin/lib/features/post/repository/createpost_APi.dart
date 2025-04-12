import '../model/createpost_model.dart';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'dart:io';

class CreatepostApi  {
  
  Future<bool> createPost({required String content, required List<File> attachments, String visibility='anyone'}) async {
    try {
      
      final response = await RequestService.postMultipart(
        Constants.createPostEndpoint,
        file: attachments.isNotEmpty ? attachments[0] : null,
        fileFieldName: 'files',
        additionalFields: {
          'description': content,
          'whoCanSee': visibility.toLowerCase(),
        },
      );

       if (response.statusCode == 201 ) {
      debugPrint('Post created successfully: ${response.body}');
      return true;
    } else {
      debugPrint('Failed to create post: ${response.statusCode} - ${response.body}');
      return false;
    }
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }
}