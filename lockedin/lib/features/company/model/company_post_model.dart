class CompanyPost {
  final String id;
  final String description;
  final List<String> attachments;
  final DateTime createdAt;
  final int commentCount;
  final int repostCount;
  final Map<String, dynamic> impressionCounts;
  final String companyName;
  final String companyLogoUrl;

  CompanyPost({
    required this.id,
    required this.description,
    required this.attachments,
    required this.createdAt,
    required this.commentCount,
    required this.repostCount,
    required this.impressionCounts,
    required this.companyName,
    required this.companyLogoUrl,
  });
  factory CompanyPost.fromJson(Map<String, dynamic> json) {
    return CompanyPost(
      id: json['postId'],
      description: json['description'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      commentCount: json['commentCount'] ?? 0,
      repostCount: json['repostCount'] ?? 0,
      impressionCounts: Map<String, dynamic>.from(
        json['impressionCounts'] ?? {},
      ),
      companyName: (json['companyId']?['name'] as String?) ?? 'Unknown Company',
      companyLogoUrl:
          json['companyId'] != null && json['companyId']['logo'] is String
              ? json['companyId']['logo']
              : '',
    );
  }
}
