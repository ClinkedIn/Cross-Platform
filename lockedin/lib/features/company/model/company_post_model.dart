class PostModel {
  final String title;
  final String description;
  final String imageUrl;
  final int likes;
  final int comments;
  final int reposts;
  final String timeAgo;

  PostModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.timeAgo,
  });
}
