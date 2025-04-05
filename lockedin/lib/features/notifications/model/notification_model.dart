class NotificationModel {
  final int id;
  final String username;
  final String secondUsername;
  final String activityType; // e.g., "posted", "commented on"
  final String description;
  final String additionalDescription;
  final String timeAgo; // e.g., "15m", "45m", "4h"
  final String profileImageUrl;
  bool isSeen;
  bool isRead; // Default value is false
  bool isPlaceholder;

  NotificationModel({
    required this.id,
    required this.username,
    required this.activityType,
    required this.description,
    required this.timeAgo,
    required this.profileImageUrl,
    this.isSeen = false,
    this.isRead = false,
    this.secondUsername = "",
    this.additionalDescription = "", //"Undo" for showLessLikeThis
    this.isPlaceholder = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      username: json['username'],
      secondUsername: json['secondUsername'] ?? "",
      activityType: json['activityType'],
      description: json['description'],
      timeAgo: json['timeAgo'],
      profileImageUrl: json['profileImageUrl'],
      isRead: json['isRead'] ?? false,
      isSeen: json['isSeen'] ?? false,
      isPlaceholder: json['isPlaceholder'] ?? false,
      additionalDescription: json['additionalDescription'] ?? "",
    );
  }
}
