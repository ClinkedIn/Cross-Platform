import '../repository/createpost_repository.dart';
import '../model/createpost_model.dart'; // Import the CreatePostModel class
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // Import the File class

class CreatepostApi implements CreatePostRepository {

  final String _baseUrl = 'https://your-api-endpoint.com/api'; // Replace with your actual API base URL
  
  @override
  Future<void> createPost(String content, String imagePath, String visibility) async {
    try {
      // Create the post model
      final postModel = CreatePostModel(
        description: content,
        imageFile: File(imagePath.isNotEmpty ? imagePath : ''),
        visibility: visibility ?? 'Anyone',
      );
      if (content.isEmpty || imagePath.isEmpty || visibility.isEmpty) {
        throw Exception('Invalid input data');
        
      }
      
      // Prepare request headers
      final headers = {
       // 'Authorization': 'Bearer $token',
      };
      
      // If there's no image file, send a simple JSON request
      if (postModel.imageFile == null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/posts'),
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(postModel.toJson()),
        );
        
        _handleResponse(response);
        return;
      } 
      // If there's an image file, send a multipart request
      else {
          // Create multipart request
        final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/posts'));
        
        // Add headers
       // request.headers.addAll(headers);
        
        // Add text fields
        request.fields['description'] = postModel.description;
        request.fields['visibility'] = postModel.visibility;
        
        // Add file
        request.files.add(await http.MultipartFile.fromPath(
          'image', 
          postModel.imageFile?.path ?? '',
        ));
        
        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        _handleResponse(response);
        return;
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  void _handleResponse(http.Response response) {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            debugPrint('Request successful: ${response.body}');
          } else {
            throw Exception('Failed to create post: ${response.statusCode} - ${response.body}');
          }
        }
}