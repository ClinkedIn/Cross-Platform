class PostModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final int likes;
  final int comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.likes,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      content: json['content'],
      likes: json['likes'],
      comments: json['comments'],
    );
  }
}
