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
  });

  // Create a copy of this Chat with modified fields
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
    );
  }

  // Create a Chat object from the API JSON response
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
    );
  }

  // Convert this Chat object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'chatType': chatType,
      'unreadCount': unreadCount,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'isSentByUser': isSentByUser,
      'timestamp': timestamp.toIso8601String(),
      'senderName': senderName,
    };
  }
}