/// A model representing a single notification in the app.
class NotificationModel {
  final String id;
  final String from;
  final String to;
  final String subject;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String resourceId;
  final String relatedPostId;
  final String relatedCommentId;
  bool isRead;
  bool isSeen;
  bool isPlaceholder;
  final SendingUser sendingUser;

  // New field for timeAgo
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now'; // Optional, for very recent times
    }
  }

  /// Creates a [NotificationModel] instance with the given data.
  NotificationModel({
    required this.id,
    required this.from,
    required this.to,
    required this.subject,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.resourceId = "",
    this.relatedPostId = "",
    this.relatedCommentId = "",
    this.isRead = false,
    this.isSeen = false,
    this.isPlaceholder = false,
    required this.sendingUser,
  });

  /// Factory constructor to create a [NotificationModel] from a JSON map.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      from: json['from'],
      to: json['to'],
      subject: json['subject'],
      content: json['content'],
      resourceId: json['resourceId'] ?? "",
      relatedPostId: json['relatedPostId'] ?? "",
      relatedCommentId: json['relatedCommentId'] ?? "",
      isRead: json['isRead'] ?? false,
      isSeen: json['isSeen'] ?? false,
      isPlaceholder: json['isPlaceholder'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sendingUser: SendingUser.fromJson(json['sendingUser']),
    );
  }
}

class SendingUser {
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  SendingUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory SendingUser.fromJson(Map<String, dynamic> json) {
    return SendingUser(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
    );
  }
}