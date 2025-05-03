class CompanyJob {
  final String companyId;
  final String workplaceType;
  final String jobLocation;
  final String jobType;
  final String description;
  final String applicationEmail;
  final List<Map<String, dynamic>> screeningQuestions;
  final bool autoRejectMustHave;
  final String rejectPreview;
  final String id;
  final List<String> applicants;
  final List<String> accepted;
  final List<String> rejected;
  final DateTime updatedAt;
  final DateTime createdAt;

  CompanyJob({
    required this.companyId,
    required this.workplaceType,
    required this.jobLocation,
    required this.jobType,
    required this.description,
    required this.applicationEmail,
    required this.screeningQuestions,
    required this.autoRejectMustHave,
    required this.rejectPreview,
    required this.id,
    required this.applicants,
    required this.accepted,
    required this.rejected,
    required this.updatedAt,
    required this.createdAt,
  });

  factory CompanyJob.fromJson(Map<String, dynamic> json) {
    return CompanyJob(
      companyId: json['companyId'] ?? '',
      workplaceType: json['workplaceType'] ?? '',
      jobLocation: json['jobLocation'] ?? '',
      jobType: json['jobType'] ?? '',
      description: json['description'] ?? '',
      applicationEmail: json['applicationEmail'] ?? '',
      screeningQuestions: List<Map<String, dynamic>>.from(
        json['screeningQuestions'] ?? [],
      ),
      autoRejectMustHave: json['autoRejectMustHave'] ?? false,
      rejectPreview: json['rejectPreview'] ?? '',
      id: json['_id'] ?? '',
      applicants: List<String>.from(json['applicants'] ?? []),
      accepted: List<String>.from(json['accepted'] ?? []),
      rejected: List<String>.from(json['rejected'] ?? []),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
