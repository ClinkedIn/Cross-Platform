class Chat {
  final String id;
  final String name;
  final String chatType; // 'direct' or 'group'
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
    required this.participants,
  });
}

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

  // Convert JSON to ChatParticipant
  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  // Convert ChatParticipant to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
    };
  }
}