import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';

class SavedPostsApi {
  Future<List<PostModel>> fetchSavedPosts() async {
    try {
      debugPrint('🔍 Starting to fetch saved posts...');
      final response = await RequestService.get(Constants.getsavedendpoint);
      debugPrint('📊 API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Debug the raw response
        debugPrint(
          'Raw API response: ${response.body.substring(0, min(100, response.body.length))}...',
        );

        // Parse the JSON content
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the posts field exists
        if (!data.containsKey('posts')) {
          debugPrint(
            'API response missing "posts" field: ${data.keys.join(', ')}',
          );
          return [];
        }

        final List<dynamic> postsJson = data['posts'];
        
        return postsJson.map((postJson) {
          // Similar parsing logic as in post_api.dart
          bool isLikedValue = false;
          if (postJson.containsKey('isLiked') && postJson['isLiked'] != null) {
            var isLikedField = postJson['isLiked'];
            if (isLikedField is bool) {
              isLikedValue = isLikedField;
            } else if (isLikedField is Map) {
              isLikedValue = true;
            }
          }
          
          // Company vs User post handling
          Map<String, dynamic>? companyData;
          String username;
          String profilePic;

          if (postJson['userId'] == null) {
            debugPrint('🏢 Company post detected');
            
            if (postJson['companyId'] is Map) {
              companyData = Map<String, dynamic>.from(postJson['companyId']);
            } else if (postJson['companyId'] is String && postJson['companyId'].toString().startsWith('{')) {
              try {
                final String jsonStr = postJson['companyId'].toString()
                    .replaceAll("'", '"');
                companyData = json.decode(jsonStr);
              } catch (e) {
                debugPrint('❌ Error parsing company JSON: $e');
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
            
            username = companyData?['name'] ?? 'Company';
            profilePic = companyData?['logo'] ?? '';
          } else {
            companyData = null;
            username = '${postJson['firstName'] ?? ''} ${postJson['lastName'] ?? ''}'.trim();
            profilePic = postJson['profilePicture'] ?? '';
          }
          
          return PostModel(
            id: postJson['postId'] ?? '',
            userId: postJson['userId'] ?? '',
            companyId: companyData,
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
            isRepost: postJson['isRepost'] == true,
            repostId: postJson['repostId'],
            repostDescription: postJson['repostDescription'],
            reposterId: postJson['reposterId'],
            reposterName: postJson['reposterFirstName'] != null
                ? '${postJson['reposterFirstName']} ${postJson['reposterLastName'] ?? ''}'.trim()
                : null,
            reposterProfilePicture: postJson['reposterProfilePicture'],
          );
        }).toList();
      } else {
        throw Exception(
          'Failed to load saved posts: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching saved posts: $e');
      return [];
    }
  }

  // Helper methods - copied from post_api.dart to maintain consistency
  int _extractCommentCount(Map<String, dynamic> postJson) {
    if (postJson.containsKey('commentCount')) {
      final count = postJson['commentCount'];
      if (count is int) return count;
      if (count is String) return int.tryParse(count) ?? 0;
      if (count is double) return count.toInt();
    }
    
    final alternativeNames = ['comments_count', 'comment_count', 'commentsCount'];
    for (final name in alternativeNames) {
      if (postJson.containsKey(name)) {
        final count = postJson[name];
        if (count is int) return count;
        if (count is String) return int.tryParse(count) ?? 0;
        if (count is double) return count.toInt();
      }
    }
    
    if (postJson.containsKey('comments') && postJson['comments'] is List) {
      return (postJson['comments'] as List).length;
    }
    
    return 0;
  }

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

  String? _extractFirstAttachment(Map<String, dynamic> postJson) {
    if (postJson['attachments'] != null && postJson['attachments'] is List) {
      final attachments = postJson['attachments'] as List;
      if (attachments.isNotEmpty) {
        final firstAttachment = attachments[0];
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

  String? _extractRegexMatch(RegExp regex, String input) {
    final match = regex.firstMatch(input);
    if (match != null && match.groupCount >= 1) {
      String? result = match.group(1)?.trim();
      if (result != null && result.startsWith('"') && result.endsWith('"')) {
        result = result.substring(1, result.length - 1);
      }
      return result == 'null' ? null : result;
    }
    return null;
  }
}

// Helper function for substring operations
int min(int a, int b) => a < b ? a : b;