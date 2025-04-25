class JobModel {
  final String title;
  final String id;
  final String company;
  final String companyId;
  final String location;
  final String description;
  final String experienceLevel;
  final String salaryRange;
  final bool isRemote;
  final String workplaceType;
  final String? logoUrl;
  final String? industry;
  final List<Map<String, dynamic>> screeningQuestions;

  final List<Map<String, dynamic>> applicants;
  final List<String> accepted;
  final List<String> rejected;

  String applicationStatus;

  JobModel({
    required this.title,
    required this.id,
    required this.company,
    required this.companyId,
    required this.location,
    required this.description,
    required this.experienceLevel,
    required this.salaryRange,
    required this.isRemote,
    required this.workplaceType,
    this.logoUrl,
    this.industry,
    required this.screeningQuestions,
    required this.applicants,
    required this.accepted,
    required this.rejected,
    required this.applicationStatus,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final companyData = json['company'] is Map ? json['company'] : null;
    final screeningQuestions = json['screeningQuestions'] as List?;

    final workplaceTypeRaw = json['workplaceType']?.toString() ?? 'Unknown';
    final questions =
        (screeningQuestions)?.map((q) => q as Map<String, dynamic>).toList() ??
        [];

    List<String> _parseStringList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    return JobModel(
      id: (json['_id'] ?? json['id'] ?? json['jobId'])?.toString() ?? '',
      title: json['title'] ?? 'Unknown Position',
      company:
          companyData != null
              ? (companyData['name'] ?? 'Unknown Company')
              : 'Unknown Company',
      companyId:
          companyData != null ? (companyData['_id']?.toString() ?? '') : '',
      location: json['jobLocation'] ?? 'Unknown Location',
      description: json['description'] ?? '',
      experienceLevel:
          screeningQuestions != null && screeningQuestions.isNotEmpty
              ? screeningQuestions.first['idealAnswer']?.toString() ?? 'Unknown'
              : 'Unknown',
      salaryRange: json['salaryRange']?.toString() ?? 'N/A',
      isRemote: workplaceTypeRaw.toLowerCase() == 'remote',
      workplaceType: workplaceTypeRaw,
      logoUrl: companyData != null ? companyData['logo'] : null,
      industry: json['industry'],
      screeningQuestions: questions,
      applicants:
          (json['applicants'] as List<dynamic>?)
              ?.map((applicant) => applicant as Map<String, dynamic>)
              .toList() ??
          [],
      accepted: _parseStringList(json['accepted']),
      rejected: _parseStringList(json['rejected']),
      applicationStatus: 'Not Applied',
    );
  }

  bool hasApplied(String userId) {
    return applicants.any((applicant) => applicant['userId'] == userId);
  }

  // Getter to access company name
  String get companyName => company;
}
