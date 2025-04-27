class ChatParticipant {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  ChatParticipant({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }
}

class Chat {
  final String id;
  final String name;
  final String chatType;
  final int unreadCount;
  final String imageUrl;
  final String lastMessage;
  final bool isSentByUser;
  final DateTime timestamp;
  final String senderName;
  final List<ChatParticipant> participants;

  Chat({
    required this.id,
    required this.name,
    required this.chatType,
    required this.unreadCount,
    required this.imageUrl,
    required this.lastMessage,
    required this.isSentByUser,
    required this.timestamp,
    required this.senderName,
    this.participants = const [],
  });

  // Update the fromJson factory method to parse participants
  factory Chat.fromJson(Map<String, dynamic> json) {
    // Extract profile picture URL based on chat type
    String profilePic = '';
    if (json['chatType'] == 'direct' && 
        json['participants'] != null && 
        json['participants']['otherUser'] != null) {
      profilePic = json['participants']['otherUser']['profilePicture'] ?? '';
    }
    
    // Get last message info
    String messageText = '';
    bool isMine = false;
    DateTime messageTime = DateTime.now();
    String sender = '';
    
    if (json['lastMessage'] != null) {
      messageText = json['lastMessage']['messageText'] ?? '';
      isMine = json['lastMessage']['isMine'] ?? false;
      
      if (json['lastMessage']['createdAt'] != null) {
        messageTime = DateTime.parse(json['lastMessage']['createdAt']);
      }
      
      if (json['lastMessage']['sender'] != null) {
        final senderData = json['lastMessage']['sender'];
        sender = '${senderData['firstName'] ?? ''} ${senderData['lastName'] ?? ''}'.trim();
      }
    }

    // Extract participants
    List<ChatParticipant> participants = [];
    if (json['participants'] != null) {
      // Handle different structures of participants
      if (json['participants'] is Map && json['participants']['otherUser'] != null) {
        participants.add(ChatParticipant.fromJson(json['participants']['otherUser']));
      } else if (json['participants'] is List) {
        participants = (json['participants'] as List)
            .map((p) => ChatParticipant.fromJson(p))
            .toList();
      }
    }

    return Chat(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      chatType: json['chatType'] ?? 'direct',
      unreadCount: json['unreadCount'] ?? 0,
      imageUrl: profilePic,
      lastMessage: messageText,
      isSentByUser: isMine,
      timestamp: messageTime,
      senderName: sender,
      participants: participants,
    );
  }

  // Make sure to include participants in the copyWith method
  Chat copyWith({
    String? id,
    String? name,
    String? chatType,
    int? unreadCount,
    String? imageUrl,
    String? lastMessage,
    bool? isSentByUser,
    DateTime? timestamp,
    String? senderName,
    List<ChatParticipant>? participants,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      chatType: chatType ?? this.chatType,
      unreadCount: unreadCount ?? this.unreadCount,
      imageUrl: imageUrl ?? this.imageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      isSentByUser: isSentByUser ?? this.isSentByUser,
      timestamp: timestamp ?? this.timestamp,
      senderName: senderName ?? this.senderName,
      participants: participants ?? this.participants,
    );
  }
}