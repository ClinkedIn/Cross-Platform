import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/home_page/model/comment_model.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';

class CommentsApi {
  // Cache for current user data
  static Map<String, dynamic>? _currentUserCache;
  static DateTime? _userDataFetchTime;
  
    /// Fetches detailed post data
    /// GET /posts/{postId}
    Future<PostModel> fetchPostDetail(String postId) async {
      try {
        final String formattedEndpoint = Constants.postDetailEndpoint.replaceFirst('%s', postId);
        final response = await RequestService.get(formattedEndpoint);
        debugPrint('🔍 Fetching post detail: $postId');
        debugPrint('📊 API response status: ${response.statusCode}');

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

          // Handle isSaved field
          bool isSavedValue = false;
          if (postJson.containsKey('isSaved') && postJson['isSaved'] != null) {
            var isSavedField = postJson['isSaved'];
            if (isSavedField is bool) {
              isSavedValue = isSavedField;
            } else if (isSavedField is Map) {
              isSavedValue = true;
            } else if (isSavedField is String) {
              isSavedValue = isSavedField.toLowerCase() == 'true';
            }
            debugPrint('💾 Post ${postJson['postId']} isSaved: $isSavedValue');
          }
          
          // *** COMPANY vs USER POST HANDLING ***
          Map<String, dynamic>? companyData;
          String username;
          String profilePic;

          if (postJson['userId'] == null) {
            debugPrint('🏢 Company post detected');
            
            // Check the actual type of companyId
            if (postJson['companyId'] is Map) {
              // It's already a Map, use it directly
              debugPrint('💼 Company data is a map');
              companyData = Map<String, dynamic>.from(postJson['companyId']);
            } else if (postJson['companyId'] is String && postJson['companyId'].toString().startsWith('{')) {
              // It's a string that looks like JSON, try to parse it
              debugPrint('💼 Company data is a string that looks like JSON');
              try {
                // Try to parse the string as JSON
                final String jsonStr = postJson['companyId'].toString()
                    .replaceAll("'", '"');  // Replace single quotes with double quotes
                companyData = json.decode(jsonStr);
              } catch (e) {
                debugPrint('❌ Error parsing company JSON: $e');
                // If parsing fails, extract data using regex
                final String companyIdStr = postJson['companyId'].toString();
                
                final RegExp idRegex = RegExp(r'_id: ([^,}]+)');
                final RegExp nameRegex = RegExp(r'name: ([^,}]+)');
                final RegExp addressRegex = RegExp(r'address: ([^,}]+)');
                final RegExp industryRegex = RegExp(r'industry: ([^,}]+)');
                final RegExp sizeRegex = RegExp(r'organizationSize: ([^,}]+)');
                final RegExp typeRegex = RegExp(r'organizationType: ([^,}]+)');
                
                companyData = {
                  "_id": _extractRegexMatch(idRegex, companyIdStr),
                  "name": _extractRegexMatch(nameRegex, companyIdStr) ?? "Company",
                  "address": _extractRegexMatch(addressRegex, companyIdStr),
                  "industry": _extractRegexMatch(industryRegex, companyIdStr),
                  "organizationSize": _extractRegexMatch(sizeRegex, companyIdStr),
                  "organizationType": _extractRegexMatch(typeRegex, companyIdStr),
                  "logo": postJson['companyLogo'],
                  "tagLine": null,
                };
              }
            } else {
              // It's a simple string ID or null
              debugPrint('💼 Company ID is simple string: ${postJson['companyId']}');
              companyData = {
                "_id": postJson['companyId'],
                "name": postJson['companyName'] ?? "Company",
                "address": postJson['companyAddress'] ?? "",
                "industry": postJson['companyIndustry'] ?? "",
                "organizationSize": postJson['companySize'] ?? "",
                "organizationType": postJson['companyType'] ?? "",
                "logo": postJson['companyLogo'],
                "tagLine": postJson['companyTagLine'] ?? "",
              };
            }
            
            // Use company name and logo for username and profile picture
            username = companyData?['name'] ?? 'Company';
            profilePic = companyData?['logo'] ?? '';
            
            // Add debug output for the parsed company data
            debugPrint('📊 Parsed company data: name=${companyData?["name"]}, industry=${companyData?["industry"]}, size=${companyData?["organizationSize"]}');
          } else {
            // This is a user post, set user data
            debugPrint('👤 User post detected');
            companyData = null; // Company data is null for user posts
            username = '${postJson['firstName'] ?? ''} ${postJson['lastName'] ?? ''}'.trim();
            profilePic = postJson['profilePicture'] ?? '';
            debugPrint('👤 User data: name=$username, profilePic=$profilePic');
          }

          // Map the API response to our PostModel
          return PostModel(
            id: postJson['postId'] ?? '',
            userId: postJson['userId'] ?? '',
            companyId: companyData, // Set company data correctly
            username: username,
            profileImageUrl: profilePic,
            content: postJson['postDescription'] ?? '',
            time: _formatTimeAgo(postJson['createdAt']),
            isEdited: postJson['isEdited'] ?? false,
            imageUrl: _extractFirstAttachment(postJson),
            mediaType: _extractFirstMediaType(postJson),
            likes: postJson['impressionCounts']?['total'] ?? 0,
            comments: _extractCommentCount(postJson),
            reposts: postJson['repostCount'] ?? 0,
            isLiked: isLikedValue,
            isMine: postJson['isMine'] ?? false,
            isSaved: isSavedValue,
            isRepost: postJson['isRepost'] ?? false,
            repostId: postJson['repostId'],
            repostDescription: postJson['repostDescription'],
            reposterId: postJson['reposterId'],
            reposterName: postJson['reposterFirstName'] != null
                ? '${postJson['reposterFirstName']} ${postJson['reposterLastName'] ?? ''}'.trim()
                : null,
            reposterProfilePicture: postJson['reposterProfilePicture'],
            taggedUsers: _extractTaggedUsers(postJson),
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

    // Add these helper methods to your CommentsApi class

    String? _extractRegexMatch(RegExp regex, String input) {
      final match = regex.firstMatch(input);
      if (match != null && match.groupCount >= 1) {
        String? result = match.group(1)?.trim();
        // Remove leading/trailing quotes if present
        if (result != null && result.startsWith('"') && result.endsWith('"')) {
          result = result.substring(1, result.length - 1);
        }
        return result == 'null' ? null : result;
      }
      return null;
    }

    String? _extractFirstAttachment(Map<String, dynamic> postJson) {
      if (postJson['attachments'] != null && postJson['attachments'] is List) {
        final attachments = postJson['attachments'] as List;
        if (attachments.isNotEmpty) {
          final firstAttachment = attachments[0];
          // Check if the attachment is a map with a URL or just a string URL
          if (firstAttachment is Map) {
            return firstAttachment['url'];
          } else if (firstAttachment is String) {
            return firstAttachment;
          }
        }
      }
      return null;
    }

    String? _extractFirstMediaType(Map<String, dynamic> postJson) {
      if (postJson['attachments'] != null && postJson['attachments'] is List) {
        final attachments = postJson['attachments'] as List;
        if (attachments.isNotEmpty) {
          final firstAttachment = attachments[0];
          if (firstAttachment is Map && firstAttachment.containsKey('mediaType')) {
            return firstAttachment['mediaType'];
          }
        }
      }
      return null;
    }

    int _extractCommentCount(Map<String, dynamic> postJson) {
      // Debug the available fields for troubleshooting
      debugPrint('Available post fields for comment count: ${postJson.keys.join(', ')}');
      
      // Try the standard field name first
      if (postJson.containsKey('commentCount')) {
        final count = postJson['commentCount'];
        debugPrint('Found commentCount: $count (${count.runtimeType})');
        
        if (count is int) {
          return count;
        } else if (count is String) {
          return int.tryParse(count) ?? 0;
        } else if (count is double) {
          return count.toInt();
        }
      }
      
      // Try alternative field names
      final alternativeNames = ['comments_count', 'comment_count', 'commentsCount'];
      for (final name in alternativeNames) {
        if (postJson.containsKey(name)) {
          final count = postJson[name];
          debugPrint('Found $name: $count');
          if (count is int) return count;
          if (count is String) return int.tryParse(count) ?? 0;
          if (count is double) return count.toInt();
        }
      }
      
      // Check if there's a comments array we can count
      if (postJson.containsKey('comments') && postJson['comments'] is List) {
        final count = (postJson['comments'] as List).length;
        debugPrint('Counted comments array length: $count');
        return count;
      }
      
      // If all else fails, log and return 0
      debugPrint('Could not find comment count field in post data');
      return 0;
    }

    List<TaggedUser> _extractTaggedUsers(Map<String, dynamic> postJson) {
      List<TaggedUser> taggedUsers = [];
      
      if (postJson.containsKey('taggedUsers') && postJson['taggedUsers'] is List) {
        final List<dynamic> taggedUsersJson = postJson['taggedUsers'];
        debugPrint('📌 Found ${taggedUsersJson.length} tagged users in post: ${postJson['postId']}');
        
        try {
          taggedUsers = taggedUsersJson
              .map((user) => TaggedUser.fromJson(user))
              .toList();
        } catch (e) {
          debugPrint('❌ Error parsing tagged users: $e');
        }
      }
      
      return taggedUsers;
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

    // Make getCurrentUserData public
    Future<Map<String, dynamic>> getCurrentUserData() async {
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
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data.containsKey('user')) {
            _currentUserCache = data['user'];
            _userDataFetchTime = now;
            return _currentUserCache!;
          } else {
            throw Exception('User data not found in response');
          }
        } else {
          throw Exception('Failed to get user data: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Error getting current user data: $e');
        rethrow;
      }
    }

    /// Search for users by name
    Future<List<TaggedUser>> searchUsers(String query, {int page = 1, int limit = 10}) async {
      try {
        if (query.length < 2) {
          return [];
        }
        
        // Build query parameters
        final queryParams = {
          'name': query,
          'page': page.toString(),
          'limit': limit.toString(),
        };
        
        // Create query string
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        
        // Get the search endpoint
        final endpoint = '${Constants.searchUsersEndpoint}?$queryString';
        
        debugPrint('🔍 Searching users with query: "$query"');
        final response = await RequestService.get(endpoint);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['users'] == null || !(data['users'] is List)) {
            debugPrint('❌ No users found or invalid response format');
            return [];
          }
          
          final List<dynamic> usersJson = data['users'];
          debugPrint('✅ Found ${usersJson.length} users');
          
          return usersJson.map((user) => TaggedUser.fromJson(user)).toList();
        } else {
          debugPrint('❌ Failed to search users: ${response.statusCode}');
          return [];
        }
      } catch (e) {
        debugPrint('❌ Error searching users: $e');
        return [];
      }
    }

    /// Adds a new comment to a post with optional tagged users
    Future<CommentModel> addComment(String postId, String content, {List<TaggedUser>? taggedUsers}) async {
      try {
        // Get current user data
        final userData = await getCurrentUserData();
        
        // Extract user information
        final userId = userData['_id'] ?? '';
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final profileImage = userData['profilePicture'] ?? '';
        final headline = userData['lastJobTitle'] ?? '';
        
        debugPrint('👤 Adding comment with user: $firstName $lastName');
        debugPrint('📝 Comment content: "$content" for postId: "$postId"');
        
        // Get the endpoint
        final String endpointToUse = Constants.addCommentEndpoint.contains('%s') 
            ? Constants.addCommentEndpoint.replaceFirst('%s', postId)
            : Constants.addCommentEndpoint;
        
        // Prepare fields for multipart request
        Map<String, dynamic> fields = {
          'postId': postId,
          'commentContent': content,
        };
        
        // Add tagged users if available
        if (taggedUsers != null && taggedUsers.isNotEmpty) {
          // Convert tagged users to JSON string
          final taggedUsersJson = jsonEncode(
            taggedUsers.map((user) => user.toJson()).toList()
          );
          fields['taggedUsers'] = taggedUsersJson;
        }
        
        debugPrint('📤 Sending comment data: $fields');
        
        final response = await RequestService.postMultipart(
          endpointToUse,
          additionalFields: fields,
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
        rethrow;
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