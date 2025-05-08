class Report {
  final ReportDetail report;
  final ReportedPost? reportedPost;
  final ReportedUser? reportedUser;

  Report({required this.report, this.reportedPost, this.reportedUser});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      report: ReportDetail.fromJson(json['report'] ?? {}),
      reportedPost:
          json['reportedPost'] != null
              ? ReportedPost.fromJson(json['reportedPost'])
              : null,
      reportedUser:
          json['reportedUser'] != null
              ? ReportedUser.fromJson(json['reportedUser'])
              : null,
    );
  }
}

class ReportDetail {
  final String id;
  final User? user;
  final String reportedId;
  final String reportedType;
  final String? status;
  final String? policy;
  final String? dontWantToSee;
  final String? moderationReason;
  final String? createdAt;
  final String? updatedAt;

  ReportDetail({
    required this.id,
    this.user,
    required this.reportedId,
    required this.reportedType,
    this.status,
    this.policy,
    this.dontWantToSee,
    this.moderationReason,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      id: json['_id'] ?? '',
      user: json['userId'] != null ? User.fromJson(json['userId']) : null,
      reportedId: json['reportedId'] ?? '',
      reportedType: json['reportedType'] ?? '',
      status: json['status'],
      policy: json['policy'],
      dontWantToSee: json['dontWantToSee'],
      moderationReason: json['moderationReason'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ReportedPost {
  final String id;
  final String description;
  final User user;
  final List<String> attachments;
  final ImpressionCounts impressionCounts;
  final int commentCount;
  final int repostCount;
  final String whoCanSee;
  final String whoCanComment;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ReportedPost({
    required this.id,
    required this.description,
    required this.user,
    required this.attachments,
    required this.impressionCounts,
    required this.commentCount,
    required this.repostCount,
    required this.whoCanSee,
    required this.whoCanComment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportedPost.fromJson(Map<String, dynamic> json) {
    return ReportedPost(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      user: User.fromJson(json['userId'] ?? {}),
      attachments: List<String>.from(json['attachments'] ?? []),
      impressionCounts: ImpressionCounts.fromJson(
        json['impressionCounts'] ?? {},
      ),
      commentCount: json['commentCount'] ?? 0,
      repostCount: json['repostCount'] ?? 0,
      whoCanSee: json['whoCanSee'] ?? '',
      whoCanComment: json['whoCanComment'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class ImpressionCounts {
  final int like;
  final int support;
  final int celebrate;
  final int love;
  final int insightful;
  final int funny;
  final int total;

  ImpressionCounts({
    required this.like,
    required this.support,
    required this.celebrate,
    required this.love,
    required this.insightful,
    required this.funny,
    required this.total,
  });

  factory ImpressionCounts.fromJson(Map<String, dynamic> json) {
    return ImpressionCounts(
      like: json['like'] ?? 0,
      support: json['support'] ?? 0,
      celebrate: json['celebrate'] ?? 0,
      love: json['love'] ?? 0,
      insightful: json['insightful'] ?? 0,
      funny: json['funny'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class ReportedUser {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? profilePicture;

  ReportedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.profilePicture,
  });

  factory ReportedUser.fromJson(Map<String, dynamic> json) {
    return ReportedUser(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      profilePicture: json['profilePicture'],
    );
  }
}

class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePicture;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profilePicture: json['profilePicture'],
    );
  }
}

// Function to parse the API response
List<Report> parseReports(Map<String, dynamic> responseJson) {
  final data = responseJson['data'] as List;
  return data.map((item) => Report.fromJson(item)).toList();
}
