class Report {
  final ReportDetail report;
  final ReportedPost? reportedPost;
  final ReportedUser? reportedUser;

  Report({required this.report, this.reportedPost, this.reportedUser});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      report: ReportDetail.fromJson(json['report']),
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
  final String? status;
  final String? reason;

  ReportDetail({required this.id, this.user, this.status, this.reason});

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      id: json['_id'],
      user: json['userId'] != null ? User.fromJson(json['userId']) : null,
      status: json['status'],
      reason: json['policy'],
    );
  }
}

class ReportedPost {
  final String id;
  final String description;
  final User user;

  ReportedPost({
    required this.id,
    required this.description,
    required this.user,
  });

  factory ReportedPost.fromJson(Map<String, dynamic> json) {
    return ReportedPost(
      id: json['_id'],
      description: json['description'],
      user: User.fromJson(json['userId']),
    );
  }
}

class ReportedUser {
  final String id;
  final String firstName;
  final String lastName;

  ReportedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory ReportedUser.fromJson(Map<String, dynamic> json) {
    return ReportedUser(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicture;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profilePicture: json['profilePicture'],
    );
  }
}
