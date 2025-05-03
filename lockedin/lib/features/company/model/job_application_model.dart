class JobApplication {
  final String applicationId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastViewed;
  final Map<String, dynamic> applicant;
  final String contactEmail;
  final String contactPhone;
  final List<Map<String, dynamic>> screeningAnswers;
  final String rejectionReason;
  final bool autoRejected;

  JobApplication({
    required this.applicationId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lastViewed,
    required this.applicant,
    required this.contactEmail,
    required this.contactPhone,
    required this.screeningAnswers,
    required this.rejectionReason,
    required this.autoRejected,
  });

factory JobApplication.fromJson(Map<String, dynamic> json) {
  return JobApplication(
    applicationId: json['applicationId'] ?? '',
    status: json['status'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    lastViewed: json['lastViewed'] != null
        ? DateTime.parse(json['lastViewed'])
        : DateTime.now(),
    applicant: Map<String, dynamic>.from(json['applicant'] ?? {}),
    contactEmail: json['contactEmail'] ?? '',
    contactPhone: json['contactPhone'] ?? '',
    screeningAnswers: List<Map<String, dynamic>>.from(
      json['screeningAnswers'] ?? [],
    ),
    rejectionReason: json['rejectionReason'] ?? '',
    autoRejected: json['autoRejected'] ?? false,
  );
}
}