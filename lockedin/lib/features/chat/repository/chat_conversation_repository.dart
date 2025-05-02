// chat_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'dart:io';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class ChatConversationRepository {
  final AuthService _authService;
  String? _receiverId; // Add this to store the receiver ID
  
  ChatConversationRepository(this._authService);

  // Getter for receiverId
  String? get receiverId => _receiverId;

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
          if (jsonData['success'] == true) {
            // Extract the receiver ID from the otherUser field at the root level
            if (jsonData['otherUser'] != null) {
              _receiverId = jsonData['otherUser']['_id'];
              debugPrint('Extracted receiver ID from otherUser: $_receiverId');
            } 
            // Also try checking within chat.participants if that exists
            else if (jsonData['chat'] != null && jsonData['chat']['participants'] != null) {
              final participants = jsonData['chat']['participants'];
              
              // Check if otherUser exists in participants
              if (participants['otherUser'] != null) {
                _receiverId = participants['otherUser']['_id'];
                debugPrint('Extracted receiver ID: $_receiverId');
              } else if (participants is List) {
                // If participants is a list, find the other user
                final currentUserId = _authService.currentUser?.id;
                for (var participant in participants) {
                  if (participant['_id'] != currentUserId) {
                    _receiverId = participant['_id'];
                    debugPrint('Extracted receiver ID from list: $_receiverId');
                    break;
                  }
                }
              }
            }
            // Check members array in the chat object if otherUser wasn't found
            else if (jsonData['chat'] != null && jsonData['chat']['members'] != null) {
              final List<dynamic> members = jsonData['chat']['members'];
              final currentUserId = _authService.currentUser?.id;
              
              for (var memberId in members) {
                if (memberId != currentUserId) {
                  _receiverId = memberId;
                  debugPrint('Extracted receiver ID from members array: $_receiverId');
                  break;
                }
              }
            }
            
            // If no receiver ID was found but messages exist, try to extract from first message
            if (_receiverId == null && 
                jsonData['chat'] != null && 
                jsonData['chat']['rawMessages'] != null && 
                jsonData['chat']['rawMessages'].isNotEmpty) {
              
              final firstMessage = jsonData['chat']['rawMessages'][0];
              final currentUserId = _authService.currentUser?.id;
              
              if (firstMessage['sender'] != null && 
                  firstMessage['sender']['_id'] != null && 
                  firstMessage['sender']['_id'] != currentUserId) {
                _receiverId = firstMessage['sender']['_id'];
                debugPrint('Extracted receiver ID from first message: $_receiverId');
              }
            }
            
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
      
      // Get current user ID and receiver ID
      final currentUserId = _authService.currentUser?.id;
      final actualReceiverId = receiverId ?? _receiverId;

      // Create the request body with all string values
      final Map<String, dynamic> body = {
        'type': chatType,
        'messageText': messageText,
        'chatId': chatId.toString(), // Ensure chatId is a string
      };
      
      // Only add receiverId if we have a valid ID - don't use participants array
      if (actualReceiverId != null) {
        body['receiverId'] = actualReceiverId.toString();
      }

      // Log the request body for debugging
      debugPrint('Sending message with body: ${jsonEncode(body)}');
      
      // Use the endpoint constant for messages
      final endpoint = Constants.chatMessagesEndpoint.replaceAll('{chatId}', chatId);
      
      // Send the message
      final response = await RequestService.post(
        endpoint,
        body: body,
      );
      
      // Log response for debugging
      debugPrint('POST Response Code: ${response.statusCode}');
      debugPrint('POST Response Body: ${response.body}');
      
      // Check status code for success
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Error: Server returned status code ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
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

  Future<Map<String, dynamic>> sendMessageWithAttachment({
    required String chatId,
    required String messageText,
    required String chatType,
    required File attachment,
    required AttachmentType attachmentType,
    String? fileName,
    String? replyTo,
  }) async {
    try {
      // Make sure user data is loaded before trying to send a message
      await _authService.fetchCurrentUser();
      
      // Use the endpoint constant for messages
      final endpoint = Constants.chatMessagesEndpoint.replaceAll('{chatId}', chatId);

      // Get receiver ID
      final actualReceiverId = _receiverId;

      // Set up the body with explicitly stringified values
      final body = {
        'messageText': messageText,
        'type': chatType,
        'chatId': chatId.toString(), // Ensure chatId is a string
      };
      
      // Only add receiverId if available - don't use participants array
      if (actualReceiverId != null) {
        body['receiverId'] = actualReceiverId.toString();
      }
      
      // Log the request for debugging
      debugPrint('Sending message with attachment to chat: $chatId');
      debugPrint('File: ${attachment.path}, Type: ${attachmentType.toString()}');
      debugPrint('Receiver ID: ${_receiverId ?? "Not available"}');
      debugPrint('Request body: ${jsonEncode(body)}');
      
      // Send the message with attachment using the multipart request
      final response = await RequestService.postMultipart(
        endpoint,
        file: attachment,
        fileFieldName: 'files', // Field name must match what the server expects
        additionalFields: body,
      );
      
      // Log response for debugging
      debugPrint('Attachment POST Response Code: ${response.statusCode}');
      debugPrint('Attachment POST Response Body: ${response.body}');
      
      // Check status code for success
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Error: Server returned status code ${response.statusCode}');
        return {
          'success': false,
          'error': 'Server returned status code ${response.statusCode}: ${response.body}',
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
      debugPrint('Error sending message with attachment: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> blockUser(String? userId) async {
    if (userId == null) {
      return {
        'success': false,
        'error': 'Cannot block user: No user ID provided',
      };
    }
    
    try {
      // Use the block user endpoint from constants
      final endpoint = Constants.blockUserEndpoint.replaceAll('{userId}', userId);
      
      final response = await RequestService.patch(endpoint, body: {});
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'error': 'Server returned status code ${response.statusCode}',
        };
      }
      
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
      
      final responseData = jsonDecode(responseBody);
      
      if (responseData['message'] == 'User blocked successfully') {
        return {
          'success': true,
          'blockedUserId': responseData['blockedUserId'],
          'message': responseData['message'],
        };
      }
      
      return {
        'success': false,
        'error': responseData['message'] ?? 'Unknown API error',
      };
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> unblockUser(String? userId) async {
    if (userId == null) {
      return {
        'success': false,
        'error': 'Cannot unblock user: No user ID provided',
      };
    }
    
    try {
      // Use the unblock user endpoint from constants
      final endpoint = Constants.unblockUserEndpoint.replaceAll('{userId}', userId);
      
      final response = await RequestService.patch(endpoint, body: {});
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'error': 'Server returned status code ${response.statusCode}',
        };
      }
      
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
      
      final responseData = jsonDecode(responseBody);
      
      if (responseData['message'] == 'User unblocked successfully') {
        return {
          'success': true,
          'message': responseData['message'],
        };
      }
      
      return {
        'success': false,
        'error': responseData['message'] ?? 'Unknown API error',
      };
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<bool> isUserBlocked(String? userId) async {
    if (userId == null) {
      debugPrint('Cannot check if user is blocked: No user ID provided');
      return false;
    }
    
    try {
      // Use the isUserBlocked endpoint from constants
      final endpoint = Constants.isUserBlocked.replaceAll('{userId}', userId);
      
      final response = await RequestService.get(endpoint);
      
      if (response.statusCode != 200) {
        return false;
      }
      
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return false;
      }
      
      final responseData = jsonDecode(responseBody);
      
      return responseData['isBlocked'] ?? false;
    } catch (e) {
      debugPrint('Error checking if user is blocked: $e');
      return false;
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