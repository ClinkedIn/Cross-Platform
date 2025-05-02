// chat_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'dart:io';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';

class ChatConversationRepository {
  final AuthService _authService;
  String? _receiverId; // Store receiver ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  ChatConversationRepository(this._authService);

  // Getter for receiverId
  String? get receiverId => _receiverId;

  // Stream messages from Firebase
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Using 'timestamp' from your Firestore
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            
            // Extract user IDs to determine receiver
            final senderId = data['senderId'] ?? '';
            final currentUserId = _authService.currentUser?.id;
            
            // If the sender is not the current user, they're the receiver (for block checks)
            if (senderId != currentUserId && senderId.isNotEmpty) {
              _receiverId = senderId;
            }
            
            // Convert Firestore timestamp to DateTime
            final createdAt = data['timestamp'] is Timestamp 
                ? (data['timestamp'] as Timestamp).toDate()
                : DateTime.now();
                
            final updatedAt = data['lastUpdatedAt'] is Timestamp 
                ? (data['lastUpdatedAt'] as Timestamp).toDate() 
                : createdAt; // Fall back to createdAt if no update time
                
            // Create sender object from participants map if available
            final Map<String, dynamic> participants = 
                data['participants'] is Map ? Map<String, dynamic>.from(data['participants']) : {};
            
            final sender = MessageSender(
              id: senderId,
              firstName: participants[senderId]?['firstName'] ?? '',
              lastName: participants[senderId]?['lastName'] ?? '',
              profilePicture: participants[senderId]?['profilePicture'],
            );
            
            // Handle attachments
            List<String> attachments = [];
            AttachmentType attachmentType = AttachmentType.none;
            
            if (data['attachments'] != null) {
              if (data['attachments'] is List) {
                attachments = List<String>.from(data['attachments']);
              } else if (data['attachments'] is String && data['attachments'].isNotEmpty) {
                attachments = [data['attachments']];
              }
              
              // Determine attachment type
              if (data['attachmentType'] != null) {
                switch (data['attachmentType']) {
                  case 'image': attachmentType = AttachmentType.image; break;
                  case 'document': attachmentType = AttachmentType.document; break;
                  case 'video': attachmentType = AttachmentType.video; break;
                  case 'audio': attachmentType = AttachmentType.audio; break;
                  case 'gif': attachmentType = AttachmentType.gif; break;
                  default: attachmentType = AttachmentType.none;
                }
              }
            }
            
            return ChatMessage(
              id: doc.id,
              sender: sender,
              messageText: data['text'] ?? '',
              createdAt: createdAt,
              updatedAt: updatedAt,
              messageAttachment: attachments,
              attachmentType: attachmentType,
            );
          }).toList();
        });
  }

  // Helper method to extract receiver ID from conversation document
  Future<void> fetchReceiverIdFromConversation(String chatId) async {
    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) return;
      
      final docSnapshot = await _firestore.collection('conversations').doc(chatId).get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        
        // Extract participants array or map from the conversation document
        if (data['participants'] is List) {
          final participants = List<String>.from(data['participants']);
          for (final participantId in participants) {
            if (participantId != currentUserId) {
              _receiverId = participantId;
              break;
            }
          }
        } else if (data['participants'] is Map) {
          final participants = Map<String, dynamic>.from(data['participants']);
          for (final participantId in participants.keys) {
            if (participantId != currentUserId) {
              _receiverId = participantId;
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching receiver ID from conversation: $e');
    }
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

  getMessagesByDateStream(String chatId) {}
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final chatConversationRepositoryProvider = Provider<ChatConversationRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  return ChatConversationRepository(authService);
});