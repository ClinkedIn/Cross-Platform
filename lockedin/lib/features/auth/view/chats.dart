class Chat {
  final String name;
  final String imageUrl;
  int unreadCount;
  String lastMessage;
  final bool isSentByUser;
  final DateTime timestamp;

  Chat({
    required this.name,
    required this.imageUrl,
    required this.unreadCount,
    required this.lastMessage,
    required this.isSentByUser,
    required this.timestamp,
});
}

