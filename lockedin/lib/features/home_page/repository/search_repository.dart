import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';

class SearchRepository {
  Future<Map<String, dynamic>> searchPosts(String keyword, {int page = 1, int limit = 10}) async {
    try {
      debugPrint('🔍 Searching posts with keyword: $keyword, page: $page');
      final String endpoint = '/search/posts?keyword=$keyword&page=$page&limit=$limit';
      
      final response = await RequestService.get(endpoint);
      debugPrint('📊 Search response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['posts'] == null || !(data['posts'] is List)) {
          debugPrint('❌ No search results found or invalid response format');
          return {
            'posts': [],
            'pagination': {'total': 0, 'page': 1, 'pages': 0}
          };
        }
        
        final List<dynamic> postsJson = data['posts'];
        final Map<String, dynamic> pagination = data['pagination'] ?? {};
        
        debugPrint('✅ Found ${postsJson.length} posts. Total: ${pagination['total'] ?? 0},');
        


      // Convert JSON to PostModel objects
      final List<PostModel> posts = postsJson.map((json) {
        // Map the API response fields to your PostModel fields
        final Map<String, dynamic> mappedJson = {
          'id': json['postId'] ?? json['_id'] ?? json['id'] ?? '',
          'userId': json['userId'] ?? '',
          'username': '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
          'profileImageUrl': json['profilePicture'] ?? '',
          'content': json['postDescription'] ?? json['description'] ?? '',
          'time': json['createdAt'] ?? '',
          'isEdited': false,  // Default or from API if available
          'likes': json['impressionCounts']?['total'] ?? 0,
          'comments': json['commentCount'] ?? 0,
          'reposts': json['repostCount'] ?? 0,
          'isLiked': json['isLiked'] ?? false,
          'isMine': json['isMine'] ?? false,
          'isRepost': json['isRepost'] ?? false,
        };
        
        return PostModel.fromJson(mappedJson);
      }).toList();
      
      return {
        'posts': posts,
        'pagination': pagination
      };
      } else {
        debugPrint('❌ Failed to search posts: ${response.statusCode} - ${response.body}');
        return {
          'posts': [],
          'pagination': {'total': 0, 'page': 1, 'pages': 0}
        };
      }
    } catch (e) {
      debugPrint('❌ Error searching posts: $e');
      return {
        'posts': [],
        'pagination': {'total': 0, 'page': 1, 'pages': 0}
      };
    }
  }
}