import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';
import 'post_repository.dart';

class PostApi implements PostRepository {
  @override
  Future<Map<String, dynamic>> fetchHomeFeed({
    required int page,
    int limit = 30,
  }) async {
    try {
      debugPrint('🔍 Starting to fetch home feed...');
      final response = await RequestService.get(
        '${Constants.feedEndpoint}?pageNumber=$page&limit=$limit',
      );
      debugPrint('📊 API response status: ${response.statusCode}');

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
          // Return empty results with pagination structure
          return {
            'posts': <PostModel>[],
            'pagination': {
              'total': 0,
              'page': page,
              'limit': limit,
              'pages': 1,
              'hasNextPage': false,
              'hasPrevPage': false,
            },
          };
        }

        final List<dynamic> postsJson = data['posts'];

        // Debug the isLiked structure if posts exist
        if (postsJson.isNotEmpty && postsJson[0].containsKey('isLiked')) {
          debugPrint('isLiked type: ${postsJson[0]['isLiked'].runtimeType}');
          debugPrint('isLiked value: ${postsJson[0]['isLiked']}');
        }

        // Debug the isSaved structure if posts exist
        if (postsJson.isNotEmpty && postsJson[0].containsKey('isSaved')) {
          debugPrint('isSaved type: ${postsJson[0]['isSaved'].runtimeType}');
          debugPrint('isSaved value: ${postsJson[0]['isSaved']}');
        }

        // Convert posts JSON to PostModel objects
        final List<PostModel> postsList =
            postsJson.map<PostModel>((postJson) {
              // Simplified isLiked handling based on your API structure
              debugPrint(
                '🔄 Processing post ID: ${postJson['postId']}, userId: ${postJson['userId']}',
              );
              bool isLikedValue = false;
              if (postJson.containsKey('isLiked') &&
                  postJson['isLiked'] != null) {
                var isLikedField = postJson['isLiked'];
                if (isLikedField is bool) {
                  // Direct boolean value
                  isLikedValue = isLikedField;
                } else if (isLikedField is Map) {
                  // If isLiked is a Map/object with details, the post is liked
                  // Based on your API example, the presence of this object means it's liked
                  isLikedValue = true;
                }
              }

              bool isSavedValue = false;
              if (postJson.containsKey('isSaved') &&
                  postJson['isSaved'] != null) {
                var isSavedField = postJson['isSaved'];
                if (isSavedField is bool) {
                  // Direct boolean value
                  isSavedValue = isSavedField;
                } else if (isSavedField is Map) {
                  // If isSaved is a Map/object with details, the post is saved
                  isSavedValue = true;
                } else if (isSavedField is String) {
                  // If isSaved is a string, check if it's "true" or "false"
                  isSavedValue = isSavedField.toLowerCase() == 'true';
                }
                debugPrint(
                  '💾 Post ${postJson['postId']} isSaved: $isSavedValue',
                );
              }

              // * COMPANY vs USER POST HANDLING *
              Map<String, dynamic>? companyData;
              String username;
              String profilePic;

              // Replace the company post handling code with this better parser
              if (postJson['userId'] == null) {
                debugPrint('🏢 Company post detected');

                // Check the actual type of companyId
                if (postJson['companyId'] is Map) {
                  // It's already a Map, use it directly
                  debugPrint('💼 Company data is a map');
                  companyData = Map<String, dynamic>.from(
                    postJson['companyId'],
                  );
                } else if (postJson['companyId'] is String &&
                    postJson['companyId'].toString().startsWith('{')) {
                  // It's a string that looks like JSON, try to parse it
                  debugPrint(
                    '💼 Company data is a string that looks like JSON',
                  );
                  try {
                    // Try to parse the string as JSON
                    final String jsonStr = postJson['companyId']
                        .toString()
                        .replaceAll(
                          "'",
                          '"',
                        ); // Replace single quotes with double quotes
                    companyData = json.decode(jsonStr);
                  } catch (e) {
                    debugPrint('❌ Error parsing company JSON: $e');
                    // If parsing fails, extract data using regex
                    final String companyIdStr =
                        postJson['companyId'].toString();

                    final RegExp idRegex = RegExp(r'_id: ([^,}]+)');
                    final RegExp nameRegex = RegExp(r'name: ([^,}]+)');
                    final RegExp addressRegex = RegExp(r'address: ([^,}]+)');
                    final RegExp industryRegex = RegExp(r'industry: ([^,}]+)');
                    final RegExp sizeRegex = RegExp(
                      r'organizationSize: ([^,}]+)',
                    );
                    final RegExp typeRegex = RegExp(
                      r'organizationType: ([^,}]+)',
                    );

                    companyData = {
                      "_id": _extractRegexMatch(idRegex, companyIdStr),
                      "name":
                          _extractRegexMatch(nameRegex, companyIdStr) ??
                          "Company",
                      "address": _extractRegexMatch(addressRegex, companyIdStr),
                      "industry": _extractRegexMatch(
                        industryRegex,
                        companyIdStr,
                      ),
                      "organizationSize": _extractRegexMatch(
                        sizeRegex,
                        companyIdStr,
                      ),
                      "organizationType": _extractRegexMatch(
                        typeRegex,
                        companyIdStr,
                      ),
                      "logo": postJson['companyLogo'],
                      "tagLine": null,
                    };
                  }
                } else {
                  // It's a simple string ID or null
                  debugPrint(
                    '💼 Company ID is simple string: ${postJson['companyId']}',
                  );
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
                debugPrint(
                  '📊 Parsed company data: name=${companyData?["name"]}, industry=${companyData?["industry"]}, size=${companyData?["organizationSize"]}',
                );
              } else {
                // This is a user post, set user data
                debugPrint('👤 User post detected');
                companyData = null; // Company data is null for user posts
                username =
                    '${postJson['firstName'] ?? ''} ${postJson['lastName'] ?? ''}'
                        .trim();
                profilePic = postJson['profilePicture'] ?? '';
                debugPrint(
                  '👤 User data: name=$username, profilePic=$profilePic',
                );
                debugPrint(
                  'Post ID: ${postJson['postId']}, isMine: ${postJson['isMine']}',
                );
              }

              return PostModel(
                id: postJson['postId'] ?? '',
                userId: postJson['userId'] ?? '',
                companyId:
                    companyData, // Set to the extracted company data or null
                username: username,
                profileImageUrl: profilePic,
                content: postJson['postDescription'] ?? '',
                time: _formatTimeAgo(postJson['createdAt']),
                isEdited: false,
                imageUrl: _extractFirstAttachment(postJson),
                mediaType: _extractFirstMediaType(postJson),
                likes: postJson['impressionCounts']?['total'] ?? 0,
                comments: _extractCommentCount(postJson),
                reposts: postJson['repostCount'] ?? 0,
                isLiked: isLikedValue,
                isMine: postJson['isMine'] == true,
                isSaved: isSavedValue,
                isRepost: postJson['isRepost'] == true,
                repostId: postJson['repostId'],
                repostDescription: postJson['repostDescription'],
                reposterId: postJson['reposterId'],
                reposterName:
                    postJson['reposterFirstName'] != null
                        ? '${postJson['reposterFirstName']} ${postJson['reposterLastName'] ?? ''}'
                            .trim()
                        : null,
                reposterProfilePicture: postJson['reposterProfilePicture'],
                taggedUsers: _extractTaggedUsers(postJson),
              );
            }).toList();

        // Extract pagination information from the response
        final Map<String, dynamic> paginationData =
            data['pagination'] ??
            {
              'total': postsJson.length,
              'page': page,
              'limit': limit,
              'pages': 1,
              'hasNextPage': false,
              'hasPrevPage': false,
            };

        // Return both posts and pagination information
        return {'posts': postsList, 'pagination': paginationData};
      } else {
        throw Exception(
          'Failed to load posts: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      // Return empty results with default pagination on error
      return {
        'posts': <PostModel>[],
        'pagination': {
          'total': 0,
          'page': page,
          'limit': limit,
          'pages': 1,
          'hasNextPage': false,
          'hasPrevPage': false,
        },
      };
    }
  }

  /// Helper method to safely extract comment count from various API formats
  int _extractCommentCount(Map<String, dynamic> postJson) {
    // Debug the available fields for troubleshooting
    debugPrint(
      'Available post fields for comment count: ${postJson.keys.join(', ')}',
    );

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
    final alternativeNames = [
      'comments_count',
      'comment_count',
      'commentsCount',
    ];
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

  // Rest of your code remains the same...
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
  Future<bool> savePostById(String postId) async {
    try {
      final String formattedEndpoint = Constants.savePostEndpoint.replaceFirst(
        '%s',
        postId,
      );
      final response = await RequestService.post(formattedEndpoint, body: {});

      if (response.statusCode == 200) {
        debugPrint('Post saved successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to save post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error saving post: $e');
      return false;
    }
  }

  @override
  Future<bool> unsavePostById(String postId) async {
    try {
      final String formattedEndpoint = Constants.savePostEndpoint.replaceFirst(
        '%s',
        postId,
      );
      final response = await RequestService.delete(formattedEndpoint);

      if (response.statusCode == 200) {
        debugPrint('✅ Post unsaved successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to unsave post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error unsaving post: $e');
      rethrow;
    }
  }

  @override
  Future<bool> likePost(String postId) async {
    try {
      final String formattedEndpoint = Constants.togglelikePostEndpoint
          .replaceFirst('%s', postId);
      final response = await RequestService.post(
        formattedEndpoint,
        body: {}, // Empty body since postId is in URL
      );

      if (response.statusCode == 200) {
        debugPrint('Post liked successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to like post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
      rethrow;
    }
  }

  @override
  Future<bool> unlikePost(String postId) async {
    try {
      final String formattedEndpoint = Constants.togglelikePostEndpoint
          .replaceFirst('%s', postId);
      final response = await RequestService.delete(formattedEndpoint);

      if (response.statusCode == 200) {
        debugPrint('Post unliked successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to unlike post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error unliking post: $e');
      rethrow;
    }
  }
  // Add these new methods

  @override
  Future<bool> createRepost(String postId, {String? description}) async {
    try {
      final String formattedEndpoint = Constants.RepostEndpoint.replaceFirst(
        '%s',
        postId,
      );

      // Create the request body
      final Map<String, dynamic> body = {};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final response = await RequestService.post(formattedEndpoint, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Post reposted successfully: $postId');
        // Log the full response
        debugPrint('📥 Response status: ${response.statusCode}');
        debugPrint('📥 Response body: ${response.body}');
        return true;
      } else {
        throw Exception(
          'Failed to repost: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error creating repost: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteRepost(String repostId) async {
    try {
      final String formattedEndpoint = Constants.RepostEndpoint.replaceFirst(
        '%s',
        repostId,
      );

      final response = await RequestService.delete(formattedEndpoint);
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');
      if (response.statusCode == 200) {
        debugPrint('✅ Repost deleted successfully');
        // Log the full response
        debugPrint('📥 Response status: ${response.statusCode}');
        debugPrint('📥 Response body: ${response.body}');
        return true;
      } else {
        throw Exception(
          'Failed to delete repost: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error deleting repost: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deletePost(String postId) async {
    try {
      final String formattedEndpoint = Constants.deletePostEndpoint
          .replaceFirst('%s', postId);

      final response = await RequestService.delete(formattedEndpoint);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Post deleted successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to delete post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting post: $e');
      rethrow;
    }
  }

  @override
  Future<bool> editPost(
    String postId, {
    required String content,
    List<TaggedUser>? taggedUsers,
  }) async {
    try {
      final String formattedEndpoint = Constants.editPostEndpoint.replaceFirst(
        '%s',
        postId,
      );

      // Create request body
      final Map<String, dynamic> body = {"description": content};

      // Add tagged users if provided - USE THE SAME FORMAT AS COMMENTS API
      if (taggedUsers != null && taggedUsers.isNotEmpty) {
        debugPrint(
          '👥 Including ${taggedUsers.length} tagged users in post edit',
        );

        // Convert tagged users to JSON string - same as comment API
        final taggedUsersJson = jsonEncode(
          taggedUsers.map((user) => user.toJson()).toList(),
        );
        body["taggedUsers"] = taggedUsersJson;
      }

      final response = await RequestService.put(formattedEndpoint, body: body);

      debugPrint('📥 Edit post response status: ${response.statusCode}');
      debugPrint('📥 Edit post response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Post edited successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to edit post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error editing post: $e');
      rethrow;
    }
  }

  // Implement the methods at the end of your class
  @override
  Future<bool> reportPost(
    String postId,
    String policy, {
    String? dontWantToSee,
  }) async {
    try {
      final String formattedEndpoint = Constants.reportPostEndpoint
          .replaceFirst('%s', postId);

      // Create request body
      final Map<String, dynamic> body = {"policy": policy};

      // Add dontWantToSee if provided
      if (dontWantToSee != null) {
        body["dontWantToSee"] = dontWantToSee;
      }

      final response = await RequestService.post(formattedEndpoint, body: body);

      debugPrint('📥 Report post response status: ${response.statusCode}');
      debugPrint('📥 Report post response body: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('✅ Post reported successfully: $postId');
        return true;
      } else {
        throw Exception(
          'Failed to report post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error reporting post: $e');
      rethrow;
    }
  }

  // Update your _extractFirstAttachment method
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

  // Also update your media type extraction method
  String? _extractFirstMediaType(Map<String, dynamic> postJson) {
    if (postJson['attachments'] != null && postJson['attachments'] is List) {
      final attachments = postJson['attachments'] as List;
      if (attachments.isNotEmpty) {
        final firstAttachment = attachments[0];
        if (firstAttachment is Map &&
            firstAttachment.containsKey('mediaType')) {
          return firstAttachment['mediaType'];
        }
      }
    }
    return null;
  }

  // Add this helper method at the end of the PostApi class
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

  @override
  Future<List<TaggedUser>> searchUsers(
    String name, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Validate search term
      if (name.length < 2) {
        debugPrint('❌ Search term must be at least 2 characters');
        return [];
      }

      // Build query parameters
      final queryParams = {
        'name': name,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Create query string
      final queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      // Create endpoint with query string
      final endpoint = '${Constants.searchUsersEndpoint}?$queryString';

      debugPrint(
        '🔍 Searching users with name: "$name", page: $page, limit: $limit',
      );
      final response = await RequestService.get(endpoint);

      debugPrint('📥 Search users response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['users'] == null || !(data['users'] is List)) {
          debugPrint('❌ No users found or invalid response format');
          return [];
        }

        final List<dynamic> usersJson = data['users'];
        final pagination = data['pagination'];

        debugPrint(
          '✅ Found ${usersJson.length} users. Total: ${pagination?['totalUsers'] ?? 'unknown'}',
        );

        return usersJson.map((user) => TaggedUser.fromJson(user)).toList();
      } else {
        debugPrint(
          '❌ Failed to search users: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error searching users: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getPostLikes(
    String postId, {
    int page = 1,
  }) async {
    try {
      debugPrint('🔍 Fetching reactions for post: $postId, page: $page');
      final String endpoint = '/posts/$postId/like?page=${page}';

      final response = await RequestService.get(endpoint);
      debugPrint(
        '📊 Get post reactions response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        debugPrint(
          'Raw API response: ${response.body.substring(0, min(500, response.body.length))}',
        );

        // Check for impressions list
        if (data['impressions'] == null || !(data['impressions'] is List)) {
          debugPrint('❌ No impressions found or invalid response format');

          return {
            'impressions': [],
            'counts': {'total': 0},
            'pagination': {'currentPage': 1, 'totalPages': 1},
          };
        }

        final List<dynamic> impressionsJson = data['impressions'];
        final Map<String, dynamic> counts = data['counts'] ?? {'total': 0};
        final Map<String, dynamic> pagination =
            data['pagination'] ??
            {
              'currentPage': 1,
              'totalPages': 1,
              'hasNextPage': false,
              'hasPrevPage': false,
            };

        debugPrint(
          '✅ Found ${impressionsJson.length} reactions. Total: ${counts['total'] ?? 0}',
        );

        return {
          'impressions': impressionsJson,
          'counts': counts,
          'pagination': pagination,
        };
      } else {
        debugPrint(
          '❌ Failed to get post reactions: ${response.statusCode} - ${response.body}',
        );
        return {
          'impressions': [],
          'counts': {'total': 0},
          'pagination': {'currentPage': 1, 'totalPages': 1},
        };
      }
    } catch (e) {
      debugPrint('❌ Error getting post reactions: $e');
      return {
        'impressions': [],
        'counts': {'total': 0},
        'pagination': {'currentPage': 1, 'totalPages': 1},
      };
    }
  }

  List<TaggedUser> _extractTaggedUsers(Map<String, dynamic> postJson) {
    List<TaggedUser> taggedUsers = [];

    if (postJson.containsKey('taggedUsers') &&
        postJson['taggedUsers'] is List) {
      final List<dynamic> taggedUsersJson = postJson['taggedUsers'];
      debugPrint(
        '📌 Found ${taggedUsersJson.length} tagged users in post: ${postJson['postId']}',
      );

      try {
        taggedUsers =
            taggedUsersJson.map((user) => TaggedUser.fromJson(user)).toList();
      } catch (e) {
        debugPrint('❌ Error parsing tagged users: $e');
      }
    }

    return taggedUsers;
  }
}

// Helper function for substring operations
int min(int a, int b) => a < b ? a : b;
