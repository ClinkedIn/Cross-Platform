import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/home_page/model/comment_model.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';

class CommentsApi {
  // Cache for current user data
  static Map<String, dynamic>? _currentUserCache;
  static DateTime? _userDataFetchTime;
  
  /// Fetches current user data or uses cached version if recently fetched
  Future<Map<String, dynamic>> _getCurrentUserData() async {
    // Use cache if available and less than 5 minutes old
    final now = DateTime.now();
    if (_currentUserCache != null && _userDataFetchTime != null) {
      final difference = now.difference(_userDataFetchTime!);
      if (difference.inMinutes < 5) {
        return _currentUserCache!;
      }
    }
    
    try {
      final response = await RequestService.get(Constants.getUserDataEndpoint);
      
      if (response.statusCode == 200) {
        // Debug the raw response
        debugPrint('User data response status: ${response.statusCode}');
        
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('user')) {
          _currentUserCache = data['user'];
          _userDataFetchTime = now;
          return _currentUserCache!;
        } else {
          debugPrint('User data missing "user" field: ${data.keys.join(', ')}');
          throw Exception('User data not found in response');
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      
      // Return empty user data if we can't fetch it
      return _currentUserCache ?? {
        '_id': 'current_user_id',
        'firstName': 'Current',
        'lastName': 'User',
        'profilePicture': 'https://randomuser.me/api/portraits/men/1.jpg',
        'lastJobTitle': ''
      };
    }
  }
  /// Public accessor for current user data
    Future<Map<String, dynamic>> getCurrentUserData() async {
      // Simply call the private method
      return _getCurrentUserData();
    }
  /// Fetches detailed post data
  /// GET /posts/{postId}
  Future<PostModel> fetchPostDetail(String postId) async {
    try {
      final String formattedEndpoint = Constants.postDetailEndpoint.replaceFirst('%s', postId);
      final response = await RequestService.get(formattedEndpoint);

      if (response.statusCode == 200) {
        // Debug the raw response
        debugPrint(
          'Raw API response: ${response.body.substring(0, min(100, response.body.length))}...',
        );

        // Try to extract JSON from the response
        String jsonContent = response.body;

        // Check if the response starts with text that isn't JSON
        if (jsonContent.trim().startsWith('Post retrieved successfully')) {
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

        // Check if the post field exists
        if (!data.containsKey('post')) {
          debugPrint(
            'API response missing "post" field: ${data.keys.join(', ')}',
          );
          throw Exception('Post data not found in response');
        }

        final Map<String, dynamic> postJson = data['post'];
        
        // Handle isLiked field
        bool isLikedValue = false;
        if (postJson.containsKey('isLiked') && postJson['isLiked'] != null) {
          var isLikedField = postJson['isLiked'];
          if (isLikedField is bool) {
            isLikedValue = isLikedField;
          } else if (isLikedField is Map) {
            isLikedValue = true;
          }
        }

        // Map the API response to our PostModel
        return PostModel(
          id: postJson['postId'] ?? '',
          userId: postJson['userId'] ?? '',
          username: '${postJson['firstName'] ?? ''} ${postJson['lastName'] ?? ''}',
          profileImageUrl: postJson['profilePicture'] ?? '',
          content: postJson['postDescription'] ?? '',
          time: _formatTimeAgo(postJson['createdAt']),
          isEdited: false, // This info might not be available in the API
          imageUrl: (postJson['attachments'] != null &&
                  (postJson['attachments'] as List).isNotEmpty)
              ? postJson['attachments'][0]
              : null,
          likes: postJson['impressionCounts']?['total'] ?? 0,
          comments: postJson['commentCount'] ?? 0,
          reposts: postJson['repostCount'] ?? 0,
          isLiked: isLikedValue,
          isMine: postJson['isMine'] ?? false,
          isRepost: postJson['isRepost'] ?? false,
          repostId: postJson['repostId'] ,
          repostDescription: postJson['repostDescription'] ,
          reposterId: postJson['reposterId'] ,
          reposterName: postJson['reposterFirstName'] != null
              ? '${postJson['reposterFirstName']} ${postJson['reposterLastName'] ?? ''}'
              : null,
          reposterProfilePicture: postJson['reposterProfilePicture'],

        );
      } else {
        throw Exception(
          'Failed to load post details: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching post details: $e');
      rethrow;
    }
  }
  
  /// Fetches comments for a specific post
    Future<List<CommentModel>> fetchComments(String postId) async {
      try {
        final String formattedEndpoint = Constants.commentsEndpoint.replaceFirst('%s', postId);
        final response = await RequestService.get(formattedEndpoint);

        if (response.statusCode == 200) {
          // Debug the raw response
          debugPrint('📊 Fetching comments for postId: $postId');
          
          // Try to extract JSON from the response
          String jsonContent = response.body;
          
          // Check if the response starts with text that isn't JSON
          if (jsonContent.trim().startsWith('Comments retrieved successfully')) {
            final jsonStart = jsonContent.indexOf('{');
            if (jsonStart >= 0) {
              jsonContent = jsonContent.substring(jsonStart);
              debugPrint('📊 Extracted comments JSON: ${jsonContent.substring(0, min(50, jsonContent.length))}...');
            }
          }

          // Parse the JSON response
          final Map<String, dynamic> data = json.decode(jsonContent);
          
          // Check if the comments field exists
          if (!data.containsKey('comments')) {
            debugPrint('❌ API response missing "comments" field: ${data.keys.join(', ')}');
            return [];
          }
          
          final List<dynamic> commentsJson = data['comments'];
          debugPrint('✅ Found ${commentsJson.length} comments');
          
          return commentsJson.map((commentJson) {
            // Handle isLiked field similar to posts
            bool isLikedValue = false;
            if (commentJson.containsKey('isLiked') && commentJson['isLiked'] != null) {
              var isLikedField = commentJson['isLiked'];
              if (isLikedField is bool) {
                isLikedValue = isLikedField;
              } else if (isLikedField is Map) {
                isLikedValue = true;
              }
            }
            
            return CommentModel(
              id: commentJson['commentId'] ?? commentJson['_id'] ?? '',
              userId: commentJson['userId'] ?? '',
              username: '${commentJson['firstName'] ?? ''} ${commentJson['lastName'] ?? ''}',
              profileImageUrl: commentJson['profilePicture'] ?? '',
              content: commentJson['commentContent'] ?? commentJson['content'] ?? '',
              time: _formatTimeAgo(commentJson['createdAt']),
              isEdited: commentJson['isEdited'] ?? false,
              likes: commentJson['likeCount'] ?? 0,
              isLiked: isLikedValue,
              designation: commentJson['headline'] ?? commentJson['designation'],
            );
          }).toList();
        } else {
          throw Exception(
            'Failed to load comments: ${response.statusCode} - ${response.reasonPhrase}',
          );
        }
      } catch (e) {
        debugPrint('Error fetching comments: $e');
        return []; // Return empty list on error instead of mock data
      }
    }

 /// Adds a new comment to a post
Future<CommentModel> addComment(String postId, String content) async {
  try {
    // Get current user data
    final userData = await _getCurrentUserData();
    
    // Extract user information
    final userId = userData['_id'] ?? '';
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';
    final profileImage = userData['profilePicture'] ?? '';
    final headline = userData['lastJobTitle'] ?? '';
    
    debugPrint('👤 Adding comment with user: $firstName $lastName');
    debugPrint('📝 Comment content: "$content" for postId: "$postId"');
    
    // Get the endpoint and always include both postId and content in the body
    final String endpointToUse = Constants.addCommentEndpoint.contains('%s') 
        ? Constants.addCommentEndpoint.replaceFirst('%s', postId)
        : Constants.addCommentEndpoint;
    
    // Use the new postMultipartFlexible method instead of regular post
    final response = await RequestService.postMultipart(
      endpointToUse,
      additionalFields:  {
        'postId': postId,
        'commentContent': content,
      },
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      debugPrint('✅ Comment successfully added! Response: ${response.statusCode}');
      
      final Map<String, dynamic> data = json.decode(response.body);
      final commentJson = data['comment'] ?? {};
      
      return CommentModel(
        id: commentJson['commentId'] ?? DateTime.now().toString(),
        userId: commentJson['userId'] ?? userId,
        username: commentJson['firstName'] != null && commentJson['lastName'] != null
            ? '${commentJson['firstName']} ${commentJson['lastName']}'
            : '$firstName $lastName',
        profileImageUrl: commentJson['profilePicture'] ?? profileImage,
        content: commentJson['content'] ?? content,
        time: 'Just now',
        isLiked: false,
        designation: commentJson['headline'] ?? headline,
      );
    } else {
      debugPrint('❌ Failed to add comment: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to add comment: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error adding comment: $e');
    rethrow;  // Rethrow so the UI layer can handle displaying the error
  }
}

  /// Toggles like status for a comment
  // Future<bool> toggleLikeComment(String commentId) async {
  //   try {
  //     final String formattedEndpoint = Constants.toggleCommentLikeEndpoint.replaceFirst('%s', commentId);
  //     final response = await RequestService.post(
  //       formattedEndpoint,
  //       body: {},
  //     );
      
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     debugPrint('Error toggling comment like: $e');
  //     return true; // Mock success for development
  //   }
  // }
  
  /// Replies to a specific comment
  // Future<CommentModel> replyToComment(String postId, String parentCommentId, String content) async {
  //   try {
  //     final String formattedEndpoint = Constants.replyToCommentEndpoint
  //         .replaceFirst('%s', postId)
  //         .replaceFirst('%p', parentCommentId);
          
  //     final response = await RequestService.post(
  //       formattedEndpoint,
  //       body: {'content': content},
  //     );
      
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       final commentJson = data['comment'];
        
  //       return CommentModel(
  //         id: commentJson['commentId'] ?? DateTime.now().toString(),
  //         userId: commentJson['userId'] ?? 'current_user_id',
  //         username: '${commentJson['firstName'] ?? ''} ${commentJson['lastName'] ?? 'Current User'}',
  //         profileImageUrl: commentJson['profilePicture'] ?? '',
  //         content: commentJson['content'] ?? content,
  //         time: 'Just now',
  //         isLiked: false,
  //       );
  //     } else {
  //       throw Exception('Failed to reply to comment: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error replying to comment: $e');
      
  //     // Mock response for development
  //     return CommentModel(
  //       id: DateTime.now().toString(),
  //       userId: 'current_user_id',
  //       username: 'Current User',
  //       profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
  //       content: content,
  //       time: 'Just now',
  //     );
  //   }
  // }
  
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
}

// Helper function for substring operations
int min(int a, int b) => a < b ? a : b;