import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/networks/model/user_model.dart';

class UserSearchRepository {
  Future<Map<String, dynamic>> searchUsers(String keyword, {int page = 1, int limit = 10}) async {
    try {
      // Validate minimum length requirement
      if (keyword.trim().length < 2) {
        debugPrint('⚠️ Search term too short: ${keyword.trim().length} characters');
        return {
          'users': [],
          'pagination': {'total': 0, 'page': 1, 'pages': 0},
          'error': 'Search term must be at least 2 characters'
        };
      }
      
      // Build query parameters similar to comment_api
      final queryParams = {
        'name': keyword.trim(), // Use 'name' instead of 'keyword' to match CommentApi
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      // Create query string with proper URL encoding
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      // Get the search endpoint
      final endpoint = '${Constants.searchUsersEndpoint}?$queryString';
      
      debugPrint('🔍 Searching users with query: "$keyword", page: $page');
      final response = await RequestService.get(endpoint);
      debugPrint('📊 User search response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['users'] == null || !(data['users'] is List)) {
          debugPrint('❌ No user search results found or invalid response format');
          return {
            'users': [],
            'pagination': {'total': 0, 'page': 1, 'pages': 0}
          };
        }
        
        final List<dynamic> usersJson = data['users'];
        final Map<String, dynamic> pagination = data['pagination'] ?? {
          'total': usersJson.length,
          'page': page, 
          'pages': 1
        };
        
        debugPrint('✅ Found ${usersJson.length} users. Total: ${pagination['total'] ?? 0}');
        
        // Convert each user JSON to UserModel
        final List<UserModel> users = usersJson.map((json) {
          return UserModel(
            id: json['_id'] ?? json['id'] ?? '',
            firstName: json['firstName'] ?? '',
            lastName: json['lastName'] ?? '',
            email: json['email'] ?? '',
            profilePicture: json['profilePicture'] ?? '',
            headline: json['headline'] ?? json['title'] ?? '',
            connectionStatus: json['connectionStatus'] ?? 'none',
            currentCompany: json['currentCompany'],
            currentPosition: json['currentPosition'],
            connections: json['connections'] ?? 0,
            isFollowing: json['isFollowing'] ?? false,
          );
        }).toList();
        
        return {
          'users': users,
          'pagination': pagination
        };
      } else if (response.statusCode == 400) {
        // Handle 400 errors specifically
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Invalid search request';
        } catch (e) {
          errorMessage = 'Bad request: ${response.body}';
        }
        
        debugPrint('⚠️ API rejected search: $errorMessage');
        return {
          'users': [],
          'pagination': {'total': 0, 'page': 1, 'pages': 0},
          'error': errorMessage
        };
      } else {
        debugPrint('❌ Failed to search users: ${response.statusCode} - ${response.body}');
        return {
          'users': [],
          'pagination': {'total': 0, 'page': 1, 'pages': 0},
          'error': 'Error ${response.statusCode}: ${response.reasonPhrase}'
        };
      }
    } catch (e) {
      debugPrint('❌ Error searching users: $e');
      return {
        'users': [],
        'pagination': {'total': 0, 'page': 1, 'pages': 0},
        'error': e.toString()
      };
    }
  }
}