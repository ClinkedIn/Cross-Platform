// chat_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'dart:io';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
import 'package:lockedin/features/chat/repository/firebase_chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationRepository {
  final AuthService _authService;
  final FirebaseChatServices _firebaseService;
  
  ChatConversationRepository(this._authService, this._firebaseService);

  // Delegate to Firebase service
  String? get receiverId => _firebaseService.receiverId;

  // Delegate to Firebase service
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firebaseService.getMessagesStream(chatId);
  }

  // Delegate to Firebase service
  Future<void> fetchReceiverIdFromConversation(String chatId) async {
    await _firebaseService.fetchReceiverIdFromConversation(chatId);
  }

  // Keep the REST API implementation for sending messages
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
      final actualReceiverId = receiverId ?? this.receiverId;

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

  // Keep all original methods for attachment, block/unblock functionality
  Future<Map<String, dynamic>> sendMessageWithAttachment({
    required String chatId,
    required String messageText,
    required String chatType,
    required File attachment,
    required AttachmentType attachmentType,
    String? fileName,
    String? replyTo,
  }) async {
    // Same implementation as original
    try {
      // Make sure user data is loaded before trying to send a message
      await _authService.fetchCurrentUser();
      
      // Use the endpoint constant for messages
      final endpoint = Constants.chatMessagesEndpoint.replaceAll('{chatId}', chatId);

      // Get receiver ID
      final actualReceiverId = receiverId;

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
      debugPrint('Receiver ID: ${receiverId ?? "Not available"}');
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
    // Keep original implementation
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
    // Keep original implementation
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
    // Keep original implementation
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

  // Delegate to Firebase service
  getMessagesByDateStream(String chatId) {
    return _firebaseService.getMessagesByDateStream(chatId);
  }

  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return;
      
      // Update typing status in Firestore
      await FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatId)
        .collection('typing_indicators')
        .doc(userId)
        .set({'isTyping': isTyping}, SetOptions(merge: true));
        
    } catch (e) {
      debugPrint('Error updating typing status: $e');
    }
  }

  Stream<Map<String, bool>> getTypingStatusStream(String chatId) {
    return FirebaseFirestore.instance
      .collection('conversations')
      .doc(chatId)
      .collection('typing_indicators')
      .snapshots()
      .map((snapshot) {
        final typingStatus = <String, bool>{};
        for (final doc in snapshot.docs) {
          typingStatus[doc.id] = doc.data()['isTyping'] ?? false;
        }
        return typingStatus;
      });
  }

  Future<void> markChatAsUnreadForRecipient(String chatId, String recipientId) async {
    try {
      await FirebaseFirestore.instance.collection('conversations').doc(chatId).update({
        'unreadBy': FieldValue.arrayUnion([recipientId])
      });
    } catch (e) {
      debugPrint("Error marking chat as unread for recipient: $e");
    }
  }

}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firebaseChatServicesProvider = Provider<FirebaseChatServices>((ref) {
  final authService = ref.read(authServiceProvider);
  return FirebaseChatServices(authService);
});

final chatConversationRepositoryProvider = Provider<ChatConversationRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  final firebaseService = ref.read(firebaseChatServicesProvider);
  return ChatConversationRepository(authService, firebaseService);
});