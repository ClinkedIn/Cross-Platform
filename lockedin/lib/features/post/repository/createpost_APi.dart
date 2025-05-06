import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';

class CreatepostApi {
  
  Future<bool> createPost({
    required String content, 
    required List<File> attachments, 
    String visibility = 'anyone',
    String fileType = 'image', 
    List<TaggedUser>? taggedUsers,// Added fileType parameter with default value
  }) async {
    try {
       debugPrint('📝 Creating post with content: "$content"');
      // For a single attachment, we can use the existing RequestService.postMultipart
      final additionalFields = {
        'description': content,
        'whoCanSee': visibility.toLowerCase(),
        'fileType': fileType,
      };
      
      
        // Add tagged users if available
          // Change how tagged users are handled
          if (taggedUsers != null && taggedUsers.isNotEmpty) {
            debugPrint('👥 Including ${taggedUsers.length} tagged users in post');
            
            // For empty attachments, use a regular POST request
            if (attachments.isEmpty) {
              // Convert tagged users correctly for POST requests
              additionalFields['taggedUsers'] = jsonEncode(taggedUsers.map((user) => user.toJson()).toList());
            } else {
              // For multipart requests with files, we need to convert to a JSON string
              // This is because multipart requests don't handle complex objects well
              additionalFields['taggedUsers'] = jsonEncode(
                taggedUsers.map((user) => user.toJson()).toList()
              );

            }
          }
      
      
      if (attachments.isEmpty) {
        // No attachments - just text post with optional tagged users
        debugPrint('📄 Creating text-only post');
        final response = await RequestService.postMultipart(
          Constants.createPostEndpoint,
          additionalFields: additionalFields,
        );
        debugPrint('✅ Post created successfully: ${response.body}');
        
        debugPrint('📊 Server response: ${response.statusCode}');
        return response.statusCode == 201 || response.statusCode == 200;
      } 
      
      // If we have attachments, continue with your existing code
      else if (attachments.length == 1) {
        final file = attachments.first;
        debugPrint('🖼️ Creating post with 1 attachment: ${file.path}');
        
        final response = await RequestService.postMultipart(
          Constants.createPostEndpoint,
          file: file,
          fileFieldName: 'files',
          additionalFields: additionalFields, // Now includes taggedUsers if provided
        );
        
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint('✅ Post created successfully: ${response.body}');
          return true;
        } else {
          debugPrint('❌ Failed to create post: ${response.statusCode} - ${response.body}');
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