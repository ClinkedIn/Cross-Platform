import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class CreatepostApi {
  
  Future<bool> createPost({
    required String content, 
    required List<File> attachments, 
    String visibility = 'anyone',
    String fileType = 'image', // Added fileType parameter with default value
  }) async {
    try {
      // For a single attachment, we can use the existing RequestService.postMultipart
      if (attachments.isEmpty) {
        // No attachments - just text post
        final response = await RequestService.post(
          Constants.createPostEndpoint,
          body: {
            'description': content,
            'whoCanSee': visibility.toLowerCase(),
            'fileType': fileType,
          },
        );
        
        return response.statusCode == 201 || response.statusCode == 200;
      } 
      
      // If we have a single attachment
      else if (attachments.length == 1) {
        final file = attachments.first;
        
        // Add additional fields including fileType
        final additionalFields = {
          'description': content,
          'whoCanSee': visibility.toLowerCase(),
          'fileType': fileType,
        };
        
        final response = await RequestService.postMultipart(
          Constants.createPostEndpoint,
          file: file,
          fileFieldName: 'files', // Keep original field name
          additionalFields: additionalFields,
        );
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint('Post created successfully: ${response.body}');
          return true;
        } else {
          debugPrint('Failed to create post: ${response.statusCode} - ${response.body}');
          return false;
        }
      }
      
      // For multiple attachments, we need to handle it differently
      // Note: This is a placeholder until RequestService supports multiple file uploads
      else {
        debugPrint('Multiple attachments not yet supported in this implementation');
        
        // For now, we'll just send the first file
        final file = attachments.first;
        
        // Add additional fields including fileType
        final additionalFields = {
          'description': content,
          'whoCanSee': visibility.toLowerCase(),
          'fileType': fileType, 
        };
        
        final response = await RequestService.postMultipart(
          Constants.createPostEndpoint,
          file: file,
          fileFieldName: 'files',
          additionalFields: additionalFields,
        );
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint('Post created successfully with first attachment: ${response.body}');
          return true;
        } else {
          debugPrint('Failed to create post: ${response.statusCode} - ${response.body}');
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      return false;
    }
  }
  
  // Helper method to determine the content type based on file extension and type
  // This isn't directly used since RequestService has its own content type detection,
  // but included for reference or future use
  MediaType _getMediaType(String path, String fileType) {
    if (fileType == 'video') {
      if (path.endsWith('.mp4')) return MediaType('video', 'mp4');
      if (path.endsWith('.mov')) return MediaType('video', 'quicktime');
      if (path.endsWith('.avi')) return MediaType('video', 'x-msvideo');
      return MediaType('video', 'mp4'); // Default
    } else if (fileType == 'document') {
      if (path.endsWith('.pdf')) return MediaType('application', 'pdf');
      if (path.endsWith('.doc') || path.endsWith('.docx')) 
        return MediaType('application', 'msword');
      if (path.endsWith('.xls') || path.endsWith('.xlsx')) 
        return MediaType('application', 'vnd.ms-excel');
      return MediaType('application', 'octet-stream'); // Default
    } else {
      // Image
      if (path.endsWith('.jpg') || path.endsWith('.jpeg'))
        return MediaType('image', 'jpeg');
      if (path.endsWith('.png')) return MediaType('image', 'png');
      if (path.endsWith('.gif')) return MediaType('image', 'gif');
      return MediaType('image', 'jpeg'); // Default
    }
  }
}