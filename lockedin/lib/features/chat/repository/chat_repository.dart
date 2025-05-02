import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/core/services/auth_service.dart';

/// Repository for handling chat-related Firebase operations
class FirebaseChatRepository {
  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User ID provided from outside - could be null if not authenticated
  String? _providedUserId;
  
  // Auth service for fallback if no ID is provided
  final AuthService _authService = AuthService();
  
  // Cache control - invalidate on new login
  String? _cachedUserId;
  DateTime _lastUserCheck = DateTime.now().subtract(Duration(days: 1));

  // Constructor with optional userId parameter
  FirebaseChatRepository({String? userId}) : _providedUserId = userId;

  /// Update user ID when user changes (e.g., after login)
  void updateUserId(String? userId) {
    _providedUserId = userId;
    _cachedUserId = null; // Clear cached ID when explicitly updated
    _lastUserCheck = DateTime.now().subtract(Duration(days: 1)); // Force refresh
  }

  // Get the current user ID from the provided ID or backend
  Future<String> get _currentUserId async {
    // Skip caching logic if explicitly provided
    if (_providedUserId != null && _providedUserId!.isNotEmpty) {
      return _providedUserId!;
    }
    
    // Check if we need to refresh user data (every 30 seconds)
    final now = DateTime.now();
    final needsRefresh = now.difference(_lastUserCheck).inSeconds > 30;
    
    // Return cached ID if available and still valid
    if (_cachedUserId != null && _cachedUserId!.isNotEmpty && !needsRefresh) {
      return _cachedUserId!;
    }
    
    // Update last check timestamp
    _lastUserCheck = now;
    
    // Fallback to auth service if no ID is provided or needs refresh
    final user = _authService.currentUser;
    if (user == null) {
      // Try to fetch current user if not already loaded
      final fetchedUser = await _authService.fetchCurrentUser();
      if (fetchedUser == null) {
        print("WARNING: No authenticated user found in backend!");
        _cachedUserId = ""; // Cache empty result
        return "";
      }
      _cachedUserId = fetchedUser.id; // Cache the result
      return fetchedUser.id;
    }
    
    _cachedUserId = user.id; // Cache the result
    return user.id;
  }

  /// Force refresh of user data
  Future<String> refreshCurrentUser() async {
    _cachedUserId = null;
    _lastUserCheck = DateTime.now().subtract(Duration(days: 1)); // Force refresh
    return await _currentUserId;
  }

  /// Stream of all chats for the current user
  Stream<List<Chat>> getChatStream() async* {
    final userId = await _currentUserId;
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
            return _mapDocToChat(doc, userId);
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
      if (data['profilePicture'] != null) {
        // Extract participant IDs from the participants array
        final List<dynamic> participantIds = data['participants'] as List;
        
        // Create participant objects from the data we have in the document
        participants = participantIds.map((id) {
          // Get the fullName for this participant
          String fullName = '';
          if (data['fullName'] != null && data['fullName'][id] != null) {
            fullName = data['fullName'][id] as String;
          }
          
          // Split the full name into first and last name
          List<String> nameParts = fullName.split(' ');
          String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          
          // Get the profile picture for this participant
          String profilePicture = '';
          if (data['profilePicture'] != null && data['profilePicture'][id] != null) {
            profilePicture = data['profilePicture'][id] as String;
          }
          
          return ChatParticipant(
            id: id,
            firstName: firstName,
            lastName: lastName,
            profilePicture: profilePicture,
          );
        }).toList();
      } else if (data['participantsData'] != null) {
        // Use the participantsData field if it exists
        participants = (data['participantsData'] as List)
            .map((p) => ChatParticipant.fromJson(p))
            .toList();
      }
    }
    
    // Calculate chat name and image for direct chats
    String chatName = data['name'] ?? '';
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
      if (chatName.isEmpty && data['fullName'] != null) {
        final Map<String, dynamic> fullNames = data['fullName'] as Map<String, dynamic>;
        if (fullNames.containsKey(otherParticipant.id)) {
          chatName = fullNames[otherParticipant.id] as String;
        }
      }
    } else {
      // For group chats, use the provided image
      imageUrl = data['imageUrl'] ?? '';
    }
    
    // Handle last message data
    String lastMessage = '';
    bool isSentByUser = false;
    DateTime timestamp = DateTime.now();
    String senderName = '';
    
    if (data['lastMessage'] != null) {
      final lastMessageData = data['lastMessage'] as Map<String, dynamic>;
      lastMessage = lastMessageData['text'] ?? '';
      isSentByUser = lastMessageData['senderId'] == currentUserId;
      
      if (lastMessageData['timestamp'] != null) {
        timestamp = (lastMessageData['timestamp'] as Timestamp).toDate();
      }
      
      // Get sender name
      if (lastMessageData['senderName'] != null) {
        senderName = lastMessageData['senderName'];
      } else if (lastMessageData['senderId'] != null) {
        final senderId = lastMessageData['senderId'];
        
        // Try to find the sender in participants
        final sender = participants.firstWhere(
          (p) => p.id == senderId,
          orElse: () {
            // If not found in participants, check fullName map
            if (data['fullName'] != null && data['fullName'][senderId] != null) {
              return ChatParticipant(
                id: senderId,
                firstName: data['fullName'][senderId],
                lastName: '',
              );
            }
            return ChatParticipant(id: senderId, firstName: '', lastName: '');
          },
        );
        senderName = '${sender.firstName} ${sender.lastName}'.trim();
      }
    }
    
    // Determine unread status
    int unreadCount = 0;
    if (data['forceUnread'] == true) {
      unreadCount = 1;
    } else {
      List<dynamic> unreadBy = data['unreadBy'] ?? [];
      if (unreadBy.contains(currentUserId)) {
        unreadCount = 1; 
      }
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
  Future<void> markChatAsRead(String chatId) async {
    final userId = await _currentUserId;
    if (userId.isEmpty) return;
    
    try {
      await _firestore.collection('conversations').doc(chatId).update({
        'forceUnread': false,
        'unreadBy': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print("Error marking chat as read: $e");
      throw Exception("Failed to mark chat as read");
    }
  }
  
  /// Mark a chat as unread
  Future<void> markChatAsUnread(String chatId) async {
    final userId = await _currentUserId;
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
  Future<int> getTotalUnreadCount() async {
    final userId = await _currentUserId;
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
        
        final List<dynamic> unreadBy = data['unreadBy'] ?? [];
        if (unreadBy.contains(userId)) {
          totalUnread++;
        }
      }
      
      return totalUnread;
    } catch (e) {
      print("Error getting total unread count: $e");
      throw Exception("Failed to get unread count");
    }
  }
  
  /// Stream of total unread count
  Stream<int> getTotalUnreadCountStream() async* {
    final userId = await _currentUserId;
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
            final data = doc.data();
            
            if (data['forceUnread'] == true) {
              totalUnread++;
              continue;
            }
            
            final List<dynamic> unreadBy = data['unreadBy'] ?? [];
            if (unreadBy.contains(userId)) {
              totalUnread++;
            }
          }
          return totalUnread;
        });
  }
}