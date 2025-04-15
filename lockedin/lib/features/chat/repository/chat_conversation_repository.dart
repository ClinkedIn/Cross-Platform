// chat_service.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/auth_service.dart';


class ChatConversationRepository {
  final AuthService _authService;
  
  ChatConversationRepository(this._authService);

  Future<Map<String, dynamic>> fetchConversation(String chatId) async {
    try {
      // Validate chatId first
      if (chatId.isEmpty) {
        return {
          'success': false,
          'error': 'Invalid chat ID',
          'chat': {
            'rawMessages': [],
            'conversationHistory': []
          },
        };
      }
      
      // Check authentication first
      if (_authService.currentUser == null) {
        // Try to fetch user data
        final user = await _authService.fetchCurrentUser();
        if (user == null) {
          return {
            'success': false,
            'error': 'Authentication required',
            'chat': {
              'rawMessages': [],
              'conversationHistory': []
            },
          };
        }
      }

      // Use the chat conversation endpoint from constants
      final endpoint = Constants.chatConversationEndpoint.replaceAll('{chatId}', chatId);
      
      try {
        final response = await RequestService.get(endpoint);

        // If we have a valid response, process it
        if (response.statusCode != 200) {
          return {
            'success': false,
            'error': 'Server returned status code ${response.statusCode}',
            'chat': {
              'rawMessages': [],
              'conversationHistory': []
            },
          };
        }

        // Parse the JSON response
        try {
          final String responseBody = response.body.trim();
          final Map<String, dynamic> jsonData = jsonDecode(responseBody);
          
          // Check if response has the expected structure
          if (jsonData['success'] == true && jsonData['chat'] != null) {
            return jsonData;
          }
          
          // If success is false or not specified, handle the error
          return {
            'success': false,
            'error': jsonData['message'] ?? 'Unknown API error',
            'chat': {
              'rawMessages': [],
              'conversationHistory': []
            },
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Failed to parse server response: ${e.toString()}',
            'chat': {
              'rawMessages': [],
              'conversationHistory': []
            },
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Network error: ${e.toString()}',
          'chat': {
            'rawMessages': [],
            'conversationHistory': []
          },
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to load conversation: ${e.toString()}',
        'chat': {
          'rawMessages': [],
          'conversationHistory': []
        },
      };
    }
  }
  
  /// Sends a new message to a specific chat
  /// 
  /// Format follows API documentation:
  /// {
  ///   "receiverId": "string",   // Optional: ID of the user receiving the message
  ///   "chatId": "string",       // Required: ID of the chat conversation
  ///   "type": "direct",         // Optional: Type of chat (direct, group, etc.)
  ///   "messageText": "string",  // Optional: Text content of the message
  ///   "messageAttachment": null, // Optional: File attachments
  ///   "replyTo": null           // Optional: Message being replied to
  /// }
  Future<bool> sendMessage({
    required String chatId,
    String messageText = '',
    String chatType = 'direct',
    String? receiverId,
  }) async {
    try {
      // Make sure user data is loaded before trying to send a message
      await _authService.fetchCurrentUser();
      
      // Get the current user ID after ensuring it's loaded
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found');
        throw Exception('You must be logged in to send messages');
      }
      
      // Create the request body with only the required fields
      final Map<String, dynamic> body = {
        'chatId': chatId,
      };
      
      // Add optional fields if provided
      if (messageText.isNotEmpty) {
        body['messageText'] = messageText;
      }
      
      if (receiverId != null) {
        body['receiverId'] = receiverId;
      } else {
        // Use current user ID as fallback
        body['receiverId'] = currentUser.id;
      }
      
      if (chatType.isNotEmpty) {
        body['type'] = chatType;
      }
      
      // Log the request body for debugging
      debugPrint('Sending message with body: ${jsonEncode(body)}');
      
      // Use the endpoint constant for messages
      final endpoint = Constants.chatMessagesEndpoint.replaceAll('{chatId}', chatId);
      debugPrint('Using messages endpoint: $endpoint');
      
      // Send the message
      final response = await RequestService.post(
        endpoint,
        body: body,
      );
      
      // Check status code for success
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Error: Server returned status code ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
      
      // Check if we got HTML instead of JSON and throw an exception
      if (response.body.contains('<!DOCTYPE html>') || 
          response.body.contains('<html>') ||
          (response.body.isNotEmpty && !response.body.startsWith('{'))) {
        
        debugPrint('ERROR: Received HTML instead of JSON response');
        throw Exception('Server returned HTML instead of JSON');
      }
      
      // Parse the response if it's JSON
      if (response.body.isNotEmpty && response.body.startsWith('{')) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == false) {
          throw Exception(jsonResponse['message'] ?? 'Unknown error');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final chatConversationRepositoryProvider = Provider<ChatConversationRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  return ChatConversationRepository(authService);
}); 