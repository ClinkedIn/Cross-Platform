import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs.map((doc) {
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
                : createdAt;
                
            // Create sender object from participants map if available
            final Map<String, dynamic> participants = 
                data['participants'] is Map ? Map<String, dynamic>.from(data['participants']) : {};
            
            final sender = MessageSender(
              id: senderId,
              firstName: participants[senderId]?['firstName'] ?? '',
              lastName: participants[senderId]?['lastName'] ?? '',
              profilePicture: participants[senderId]?['profilePicture'],
            );
            
            // Handle attachments with additional logging
            List<String> attachments = [];
            AttachmentType attachmentType = AttachmentType.none;
            
            // First check for mediaUrl field
            if (data['mediaUrl'] != null && data['mediaUrl'].toString().isNotEmpty) {
              String url = data['mediaUrl'].toString();
              
              // Ensure URL has a proper scheme
              if (!url.startsWith('http://') && !url.startsWith('https://')) {

                
                // Try to fix common issues - if it starts with '//', add https:
                if (url.startsWith('//')) {
                  url = 'https:$url';
                } 
                // If it starts with '/', assume it's a relative path from your domain
                else if (url.startsWith('/')) {
                  // Use your base URL, for example:
                  url = 'https://yourdomain.com$url';
                } 
                // Otherwise, if it doesn't have a scheme at all, add https://
                else if (!url.contains('://')) {
                  url = 'https://$url';
                }
              
              }
              
              attachments = [url];
              
              // Determine attachment type from mediaType field
              if (data['mediaType'] != null) {
                final mediaType = data['mediaType'].toString().toLowerCase();
                
                switch (mediaType) {
                  case 'image': 
                    attachmentType = AttachmentType.image;
                    break;
                  case 'document': 
                    attachmentType = AttachmentType.document;
                    break;
                  // Add other cases as needed
                  default: 
                    // Auto-detect image type from URL if mediaType is not specified
                    if (url.toLowerCase().endsWith('.jpg') || 
                        url.toLowerCase().endsWith('.jpeg') || 
                        url.toLowerCase().endsWith('.png') || 
                        url.toLowerCase().endsWith('.gif') || 
                        url.contains('/image/')) {

                      attachmentType = AttachmentType.image;
                    } else {
                      attachmentType = AttachmentType.none;
                    }
                }
              } else {
                // If mediaType is not present but URL exists, try to guess from URL
                if (url.toLowerCase().endsWith('.jpg') || 
                    url.toLowerCase().endsWith('.jpeg') || 
                    url.toLowerCase().endsWith('.png') || 
                    url.toLowerCase().endsWith('.gif') || 
                    url.contains('/image/')) {

                  attachmentType = AttachmentType.image;
                }
              }
            }
            
            return ChatMessage(
              id: doc.id,
              sender: sender,
              messageText: data['text'] ?? '',
              createdAt: createdAt,
              updatedAt: updatedAt,
              // Extract first URL from attachments array rather than passing the whole array
              messageAttachment: attachments,
              attachmentType: attachmentType,
            );
          }).toList();
          
          return messages;
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
  return getMessagesStream(chatId).map((messages) {
    final Map<String, List<ChatMessage>> messagesByDate = {};
    
    for (final message in messages) {
      final dateKey = DateFormat('MMMM d, yyyy').format(message.createdAt);
      if (!messagesByDate.containsKey(dateKey)) {
        messagesByDate[dateKey] = [];
      }
      messagesByDate[dateKey]!.add(message);
    }
    
    // Sort messages within each date
    messagesByDate.forEach((date, msgs) {
      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
    
    return messagesByDate;
  });
}

  // Add these methods to handle typing status
  Stream<Map<String, bool>> getTypingStatusStream(String chatId) {
    return _firestore
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

  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;
    
    try {
      await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('typing_indicators')
        .doc(userId)
        .set({'isTyping': isTyping}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating typing status: $e');
    }
  }

  // Method to mark messages as read by the current user
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) return;
      
      // Get all unread messages in this conversation
      final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .where('readBy', whereNotIn: [currentUserId])
        .get();
      
      // Create a batch to perform multiple updates
      final batch = _firestore.batch();
      
      for (final doc in messagesSnapshot.docs) {
        // Add current user to readBy array for each message
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
      
      // Commit the batch
      await batch.commit();
      
      // Also update the conversation document to remove current user from unreadBy
      await _firestore
        .collection('conversations')
        .doc(chatId)
        .update({
          'unreadBy': FieldValue.arrayRemove([currentUserId])
        });
        
      debugPrint('Marked ${messagesSnapshot.docs.length} messages as read');
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

}

final firebaseChatServicesProvider = Provider<FirebaseChatServices>((ref) {
  final authService = ref.read(authServiceProvider);
  return FirebaseChatServices(authService);
});