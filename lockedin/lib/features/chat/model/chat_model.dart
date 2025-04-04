// chat_model.dart
class Chat {
  final String id;
  final String name;
  final String imageUrl;
  int unreadCount;
  String lastMessage;
  final bool isSentByUser;
  final DateTime timestamp;
  final bool isOnline;
  final bool isRead;

  Chat({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unreadCount,
    required this.lastMessage,
    required this.isSentByUser,
    required this.timestamp,
    this.isOnline = false,
    this.isRead = false,
  });

  Chat copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? unreadCount,
    String? lastMessage,
    bool? isSentByUser,
    DateTime? timestamp,
    bool? isOnline,
    bool? isRead,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      isSentByUser: isSentByUser ?? this.isSentByUser,
      timestamp: timestamp ?? this.timestamp,
      isOnline: isOnline ?? this.isOnline,
      isRead: isRead ?? this.isRead,
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: json['lastMessage'] ?? '',
      isSentByUser: json['isSentByUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      isOnline: json['isOnline'] ?? false,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage,
      'isSentByUser': isSentByUser,
      'timestamp': timestamp.toIso8601String(),
      'isOnline': isOnline,
      'isRead': isRead,
    };
  }
}