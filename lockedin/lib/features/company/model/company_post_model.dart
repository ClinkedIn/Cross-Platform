class CompanyPost {
  final String id;
  final String description;
  final List<String> attachments;
  final DateTime createdAt;
  final int commentCount;
  final int repostCount;
  final Map<String, dynamic> impressionCounts;

  CompanyPost({
    required this.id,
    required this.description,
    required this.attachments,
    required this.createdAt,
    required this.commentCount,
    required this.repostCount,
    required this.impressionCounts,
  });

  factory CompanyPost.fromJson(Map<String, dynamic> json) {
    return CompanyPost(
      id: json['id'],
      description: json['description'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      commentCount: json['commentCount'] ?? 0,
      repostCount: json['repostCount'] ?? 0,
      impressionCounts: json['impressionCounts'] ?? {},
    );
  }
}
