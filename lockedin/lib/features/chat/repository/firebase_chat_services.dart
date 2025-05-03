import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
import 'package:lockedin/features/chat/repository/chat_conversation_repository.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class FirebaseChatServices {
  final AuthService _authService;
  String? _receiverId; // Store receiver ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirebaseChatServices(this._authService);

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

  // Method for organizing messages by date
  Stream<Map<String, List<ChatMessage>>> getMessagesByDateStream(String chatId) {
    // Implementation depends on how you want to organize messages by date
    // This is a placeholder that you'll need to implement based on your needs
    return Stream.value({});
  }
}

final firebaseChatServicesProvider = Provider<FirebaseChatServices>((ref) {
  final authService = ref.read(authServiceProvider);
  return FirebaseChatServices(authService);
});