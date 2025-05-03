import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';

/// Repository for handling chat-related Firebase operations
class FirebaseChatRepository {
  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all chats for the current user
  Stream<List<Chat>> getChatStream(userId) async* {
    
    print("Getting chats for user ID: $userId"); // Log user ID
    
    // Check if user is authenticated, if not return empty stream
    if (userId.isEmpty) {
      print("Cannot get chats - no authenticated user");
      yield [];
      return;
    }
    
    // Use the userId to query Firebase
    yield* _firestore.collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          print("Chat snapshots received for user $userId: ${snapshot.docs.length}"); // Log number of chats
          return snapshot.docs.map((doc) {
            try {
              return _mapDocToChat(doc, userId);
            } catch (e) {
              print("Error mapping doc to chat: $e");
              // Return a placeholder chat for documents that can't be mapped
              return Chat(
                id: doc.id,
                name: "Loading...",
                chatType: 'direct',
                unreadCount: 0,
                imageUrl: '',
                lastMessage: '',
                isSentByUser: false,
                timestamp: DateTime.now(),
                senderName: '',
                participants: [],
              );
            }
          }).toList();
        });
  }

  /// Maps a Firestore document to a Chat object
  Chat _mapDocToChat(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get chat type - default to 'direct' if not specified
    final String chatType = data['chatType'] ?? 'direct';
    
    // Handle participants data
    List<ChatParticipant> participants = [];
    if (data['participants'] != null) {
      // First check if we have detailed participant data
      if (data['profilePicture'] != null && data['profilePicture'] is Map) {
        // Extract participant IDs from the participants array
        final List<dynamic> participantIds = data['participants'] as List;
        
        // Create participant objects from the data we have in the document
        participants = participantIds.map((id) {
          // Get the fullName for this participant
          String fullName = '';
          if (data['fullName'] != null && data['fullName'] is Map && (data['fullName'] as Map).containsKey(id)) {
            final nameValue = (data['fullName'] as Map)[id];
            if (nameValue is String) {
              fullName = nameValue;
            }
          }
          
          // Split the full name into first and last name
          List<String> nameParts = fullName.split(' ');
          String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          
          // Get the profile picture for this participant
          String profilePicture = '';
          if (data['profilePicture'] != null && data['profilePicture'] is Map && (data['profilePicture'] as Map).containsKey(id)) {
            final picValue = (data['profilePicture'] as Map)[id];
            if (picValue is String) {
              profilePicture = picValue;
            }
          }
          
          return ChatParticipant(
            id: id,
            firstName: firstName,
            lastName: lastName,
            profilePicture: profilePicture,
          );
        }).toList();
      } else if (data['participantsData'] != null && data['participantsData'] is List) {
        // Use the participantsData field if it exists
        participants = (data['participantsData'] as List)
            .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        // Basic participants list with just IDs
        final List<dynamic> participantIds = data['participants'] as List;
        participants = participantIds.map((id) => ChatParticipant(
          id: id.toString(),
          firstName: '',
          lastName: '',
          profilePicture: '',
        )).toList();
      }
    }
    
    // Calculate chat name and image for direct chats
    String chatName = data['name'] != null && data['name'] is String ? data['name'] : '';
    String imageUrl = '';
    
    // For direct chats, show the other user's name and profile picture
    if (chatType == 'direct' && participants.isNotEmpty) {
      // Find the other participant (not the current user)
      final otherParticipant = participants.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => participants.isNotEmpty ? participants.first : 
          ChatParticipant(id: '', firstName: '', lastName: ''),
      );
      
      // Set the chat name to the other user's name if not already set
      if (chatName.isEmpty) {
        chatName = '${otherParticipant.firstName} ${otherParticipant.lastName}'.trim();
      }
      
      // Set the chat image to the other user's profile picture
      imageUrl = otherParticipant.profilePicture ?? '';
      
      // If we still don't have a name, try to use fullName directly
      if (chatName.isEmpty && data['fullName'] != null && data['fullName'] is Map) {
        final fullNames = data['fullName'] as Map;
        if (fullNames.containsKey(otherParticipant.id)) {
          final nameValue = fullNames[otherParticipant.id];
          if (nameValue is String) {
            chatName = nameValue;
          }
        }
      }
    } else {
      // For group chats, use the provided image
      if (data['imageUrl'] != null && data['imageUrl'] is String) {
        imageUrl = data['imageUrl'];
      }
    }
    
    // Handle last message data
    String lastMessage = '';
    bool isSentByUser = false;
    DateTime timestamp = DateTime.now();
    String senderName = '';
    
    if (data['lastMessage'] != null && data['lastMessage'] is Map) {
      final lastMessageData = data['lastMessage'] as Map<String, dynamic>;
      
      if (lastMessageData['text'] != null && lastMessageData['text'] is String) {
        lastMessage = lastMessageData['text'];
      }
      
      if (lastMessageData['senderId'] != null) {
        isSentByUser = lastMessageData['senderId'] == currentUserId;
      }
      
      if (lastMessageData['timestamp'] != null && lastMessageData['timestamp'] is Timestamp) {
        timestamp = (lastMessageData['timestamp'] as Timestamp).toDate();
      }
      
      // Get sender name
      if (lastMessageData['senderName'] != null && lastMessageData['senderName'] is String) {
        senderName = lastMessageData['senderName'];
      } else if (lastMessageData['senderId'] != null) {
        final senderId = lastMessageData['senderId'];
        
        // Try to find the sender in participants
        final sender = participants.firstWhere(
          (p) => p.id == senderId,
          orElse: () {
            // If not found in participants, check fullName map
            if (data['fullName'] != null && data['fullName'] is Map && (data['fullName'] as Map).containsKey(senderId)) {
              final nameValue = (data['fullName'] as Map)[senderId];
              return ChatParticipant(
                id: senderId.toString(),
                firstName: nameValue is String ? nameValue : '',
                lastName: '',
              );
            }
            return ChatParticipant(id: senderId.toString(), firstName: '', lastName: '');
          },
        );
        senderName = '${sender.firstName} ${sender.lastName}'.trim();
      }
    }
    
    // Determine unread status
    int unreadCount = 0;
    if (data['messageCount'] != null && data['readCount'] != null && data['readCount'] is Map) {
      // Get the read count for current user
      final readCountMap = data['readCount'] as Map;
      final userReadCount = readCountMap[currentUserId] as int? ?? 0;
      // Get total message count
      final totalMessages = data['messageCount'] as int? ?? 0;
      // Calculate unread = total - read
      unreadCount = totalMessages - userReadCount;
      // Ensure we don't have negative unread count
      if (unreadCount < 0) unreadCount = 0;
    } else if (data['forceUnread'] == true) {
      // Legacy support for forceUnread
      unreadCount = 1;
    } else if (data['unreadBy'] != null && data['unreadBy'] is List) {
      // Legacy support for unreadBy array
      List<dynamic> unreadBy = data['unreadBy'];
      if (unreadBy.contains(currentUserId)) {
        unreadCount = 1;
      }
    }
    
    // Use safe default if chat name is still empty
    if (chatName.isEmpty) {
      chatName = "Conversation";
    }
    
    return Chat(
      id: doc.id,
      name: chatName,
      chatType: chatType,
      unreadCount: unreadCount,
      imageUrl: imageUrl,
      lastMessage: lastMessage,
      isSentByUser: isSentByUser,
      timestamp: timestamp,
      senderName: senderName,
      participants: participants,
    );
  }

  /// Mark a chat as read
  Future<void> markChatAsRead(String chatId, userId) async {
    if (userId.isEmpty) return;
    
    try {
      // First, get the current chat document to read the message count
      final chatDoc = await _firestore.collection('conversations').doc(chatId).get();
      final data = chatDoc.data();
      
      if (data == null) return;
      
      // Get the total message count
      final messageCount = data['messageCount'] as int? ?? 0;
      
      // Prepare the update
      Map<String, dynamic> updateData = {
        'forceUnread': false,
        'unreadBy': FieldValue.arrayRemove([userId]),
        // Update readCount for this user to match the total message count
        'readCount.$userId': messageCount
      };
      
      // Update the document
      await _firestore.collection('conversations').doc(chatId).update(updateData);
    } catch (e) {
      print("Error marking chat as read: $e");
      throw Exception("Failed to mark chat as read");
    }
  }
  
  /// Mark a chat as unread
  Future<void> markChatAsUnread(String chatId, userId) async {
    
    if (userId.isEmpty) return;
    
    try {
      await _firestore.collection('conversations').doc(chatId).update({
        'forceUnread': true,
        'unreadBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print("Error marking chat as unread: $e");
      throw Exception("Failed to mark chat as unread");
    }
  }
  
  /// Get the total unread count 
  Future<int> getTotalUnreadCount(userId) async {
    
    if (userId.isEmpty) return 0;
    
    try {
      final QuerySnapshot snapshot = await _firestore.collection('conversations')
          .where('participants', arrayContains: userId)
          .get();
          
      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        if (data['forceUnread'] == true) {
          totalUnread++;
          continue;
        }
        
        if (data['unreadBy'] != null && data['unreadBy'] is List) {
          final List<dynamic> unreadBy = data['unreadBy'];
          if (unreadBy.contains(userId)) {
            totalUnread++;
          }
        }
      }
      
      return totalUnread;
    } catch (e) {
      print("Error getting total unread count: $e");
      throw Exception("Failed to get unread count");
    }
  }
  
  /// Stream of total unread count
  Stream<int> getTotalUnreadCountStream(userId) async* {
    
    if (userId.isEmpty) {
      yield 0;
      return;
    }
    
    yield* _firestore.collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          int totalUnread = 0;
          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              
              if (data['forceUnread'] == true) {
                totalUnread++;
                continue;
              }
              
              if (data['unreadBy'] != null && data['unreadBy'] is List) {
                final List<dynamic> unreadBy = data['unreadBy'];
                if (unreadBy.contains(userId)) {
                  totalUnread++;
                }
              }
            } catch (e) {
              print("Error processing doc for unread count: $e");
              // Skip this doc and continue
            }
          }
          return totalUnread;
        });
  }

  
}