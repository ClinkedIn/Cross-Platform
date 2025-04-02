class NotificationModel {
  final String id;
  final String username;
  final String activityType; // e.g., "posted", "commented on"
  final String description;
  final String timeAgo; // e.g., "15m", "45m", "4h"
  final String profileImageUrl;
  bool isRead; // Default value is false

  NotificationModel({
    required this.id,
    required this.username,
    required this.activityType,
    required this.description,
    required this.timeAgo,
    required this.profileImageUrl,
    this.isRead = false,
  });
}
