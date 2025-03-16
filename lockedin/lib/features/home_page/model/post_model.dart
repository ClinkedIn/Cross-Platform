class PostModel {
  final String id;
  final String userId;
  final String username;
  final String profileImageUrl; // User profile picture
  final String content;
  final String time; // Example: "4d"
  final bool isEdited; // True if post was edited
  final String? imageUrl; // Post image URL (optional)
  final int likes;
  final int comments;
  final int reposts;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.content,
    required this.time,
    required this.isEdited,
    this.imageUrl, // Changed from postImageUrl to imageUrl
    required this.likes,
    required this.comments,
    required this.reposts,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
      content: json['content'],
      time: json['time'],
      isEdited: json['isEdited'] ?? false,
      imageUrl: json['imageUrl'], // Ensure JSON key matches
      likes: json['likes'],
      comments: json['comments'],
      reposts: json['reposts'],
    );
  }
}
