import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'post_repository.dart';

class PostApi implements PostRepository {
 // final String apiUrl = "https://lockedin-swagger-cncpa8fwhsbzgmcs.italynorth-01.azurewebsites.net/posts?pageNumber=1&limit=10";

  @override
  Future<List<PostModel>> fetchHomeFeed() async {
    try {
      final response = await RequestService.get(Constants.feedEndpoint);

      if (response.statusCode == 200) {
        // Debug the raw response
        debugPrint(
          'Raw API response: ${response.body.substring(0, min(100, response.body.length))}...',
        );

        // Try to extract JSON from the response
        String jsonContent = response.body;

        // Check if the response starts with text that isn't JSON
        if (jsonContent.trim().startsWith('Posts retrieved successfully')) {
          // Find the beginning of the JSON object (usually starts with '{')
          final jsonStart = jsonContent.indexOf('{');
          if (jsonStart >= 0) {
            jsonContent = jsonContent.substring(jsonStart);
            debugPrint(
              'Extracted JSON content starting with: ${jsonContent.substring(0, min(50, jsonContent.length))}...',
            );
          } else {
            throw FormatException('Could not find JSON data in response');
          }
        }

        // Parse the JSON content
        final Map<String, dynamic> data = json.decode(jsonContent);

        // Check if the posts field exists
        if (!data.containsKey('posts')) {
          debugPrint(
            'API response missing "posts" field: ${data.keys.join(', ')}',
          );
          return [];
        }

        final List<dynamic> postsJson = data['posts'];

        return postsJson.map((postJson) {
          // Map the API response to our PostModel
          return PostModel(
            id: postJson['postId'] ?? '',
            userId: postJson['userId'] ?? '',
            username:
                '${postJson['firstName'] ?? ''} ${postJson['lastName'] ?? ''}',
            profileImageUrl: postJson['profilePicture'] ?? '',
            content: postJson['postDescription'] ?? '',
            time: _formatTimeAgo(postJson['createdAt']),
            isEdited: false, // This info might not be available in the API
            imageUrl:
                (postJson['attachments'] != null &&
                        (postJson['attachments'] as List).isNotEmpty)
                    ? postJson['attachments'][0]
                    : null,
            likes: postJson['impressionCounts']?['total'] ?? 0,
            comments: postJson['commentCount'] ?? 0,
            reposts: postJson['repostCount'] ?? 0,
          );
        }).toList();
      } else {
        throw Exception(
          'Failed to load posts: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      // Return empty list on error
      return [];
    }
  }

  // Helper method to format the timestamp into a relative time string
  String _formatTimeAgo(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}m';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
   @override
  Future<void> savePostById(String postId) async {
    // Implementation to call backend API
    // Example:
    final response = await http.post(
      Uri.parse('https://lockedin-swagger-cncpa8fwhsbzgmcs.italynorth-01.azurewebsites.net/save'),
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer ${await TokenService.getToken()}',
      },
      body: jsonEncode({'postId': postId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to save post: ${response.body}');
    }
  }
}

// Helper function for substring operations
int min(int a, int b) => a < b ? a : b;
