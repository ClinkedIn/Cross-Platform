/// A model representing a single notification in the app.
class NotificationModel {
  /// Unique identifier for the notification.
  final int id;
  /// Username of the user who triggered the notification.
  final String username;
  /// (Optional) A second username involved in the notification, if applicable.
  final String secondUsername;
  /// Type of activity that triggered the notification (e.g., "posted", "commented on").
  final String activityType;
  /// Description of the notification (e.g., "John Doe posted a new job").
  final String description;
  /// Time elapsed since the notification was triggered (e.g., "15m", "45m", "4h").
  final String timeAgo;
  /// URL of the profile image of the user who triggered the notification.
  final String profileImageUrl;
  /// Indicates whether the notification has been seen by the user.
  bool isSeen;
  /// Indicates whether the notification has been read by the user.
  bool isRead;
  /// Indicates whether the notification is a placeholder (e.g., after "show less like this").
  bool isPlaceholder;

  /// Creates a [NotificationModel] instance with the given data.
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
    this.isPlaceholder = false,
  });

  /// Factory constructor to create a [NotificationModel] from a JSON map.
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
    );
  }
}
