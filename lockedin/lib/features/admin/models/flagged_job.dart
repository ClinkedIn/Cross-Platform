class ScreeningQuestion {
  final String question;
  final bool mustHave;

  ScreeningQuestion({required this.question, required this.mustHave});

  factory ScreeningQuestion.fromJson(Map<String, dynamic> json) {
    return ScreeningQuestion(
      question: json['question'],
      mustHave: json['mustHave'],
    );
  }
}

class FlaggedJob {
  final String id;
  final String jobType;
  final String workplaceType;
  final String jobLocation;
  final String description;
  final String applicationEmail;
  final List<ScreeningQuestion> screeningQuestions;
  final bool autoRejectMustHave;
  final String rejectPreview;
  final List<String> applicants;
  final List<String> accepted;
  final List<String> rejected;
  final DateTime createdAt;

  FlaggedJob({
    required this.id,
    required this.jobType,
    required this.workplaceType,
    required this.jobLocation,
    required this.description,
    required this.applicationEmail,
    required this.screeningQuestions,
    required this.autoRejectMustHave,
    required this.rejectPreview,
    required this.applicants,
    required this.accepted,
    required this.rejected,
    required this.createdAt,
  });

  factory FlaggedJob.fromJson(Map<String, dynamic> json) {
    return FlaggedJob(
      id: json['_id'],
      jobType: json['jobType'],
      workplaceType: json['workplaceType'],
      jobLocation: json['jobLocation'],
      description: json['description'],
      applicationEmail: json['applicationEmail'],
      screeningQuestions:
          (json['screeningQuestions'] as List)
              .map((q) => ScreeningQuestion.fromJson(q))
              .toList(),
      autoRejectMustHave: json['autoRejectMustHave'],
      rejectPreview: json['rejectPreview'],
      applicants: List<String>.from(json['applicants']),
      accepted: List<String>.from(json['accepted']),
      rejected: List<String>.from(json['rejected']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
