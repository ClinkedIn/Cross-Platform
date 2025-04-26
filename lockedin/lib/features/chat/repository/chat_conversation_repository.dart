// chat_service.dart
import 'dart:convert';
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
  
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String messageText,
    required String chatType,
    String? receiverId,
  }) async {
    try {
      // Make sure user data is loaded before trying to send a message
      await _authService.fetchCurrentUser();
      
      // Get the current user ID after ensuring it's loaded
      // final currentUser = _authService.currentUser;
      // if (currentUser == null) {
      //   debugPrint('No authenticated user found');
      //   throw Exception('You must be logged in to send messages');
      // }
      
      // Create the request body with the required fields according to the API spec
      final Map<String, dynamic> body = {
        'type': chatType,
        'messageText': messageText,
        'chatId': chatId,
      };
      
      // Log the request body for debugging
      debugPrint('Sending message with body: ${jsonEncode(body)}');
      
      // Use the endpoint constant for messages
      final endpoint = Constants.chatMessagesEndpoint.replaceAll('{chatId}', chatId);
      
      // Send the message
      final response = await RequestService.post(
        endpoint,
        body: body,
      );
      
      // Check status code for success
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Error: Server returned status code ${response.statusCode}');
        return {
          'success': false,
          'error': 'Server returned status code ${response.statusCode}',
        };
      }

      // Parse the response
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
      
      final responseData = jsonDecode(responseBody);
      
      // Check if the response has the expected format
      if (responseData['message'] == 'Message created successfully' && responseData['data'] != null) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      }
      
      return {
        'success': false,
        'error': responseData['message'] ?? 'Unknown API error',
      };
    } catch (e) {
      debugPrint('Error sending message: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
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