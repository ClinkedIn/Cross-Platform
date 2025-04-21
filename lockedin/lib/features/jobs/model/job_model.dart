class JobModel {
  final String title;
  final String id;
  final String company;
  final String location;
  final String description;
  final String experienceLevel;
  final String salaryRange;
  final bool isRemote;
  final String workplaceType;
  final String? logoUrl;
  final String? industry;
  final List<Map<String, dynamic>> screeningQuestions;

  // ✅ New fields from API
  final List<String> applicants;
  final List<String> accepted;
  final List<String> rejected;

  // ✅ Add application status to the model
  String
  applicationStatus; // This field will hold the status for a user's application

  JobModel({
    required this.title,
    required this.id,
    required this.company,
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
    required this.applicationStatus, // Pass status in the constructor
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final companyData = json['company'] is Map ? json['company'] : null;
    final screeningQuestions = json['screeningQuestions'] as List?;

    final workplaceTypeRaw = json['workplaceType']?.toString() ?? 'Unknown';
    final questions =
        (screeningQuestions)?.map((q) => q as Map<String, dynamic>).toList() ??
        [];

    // Parse string lists safely
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

      // ✅ Assign lists from API
      applicants: _parseStringList(json['applicants']),
      accepted: _parseStringList(json['accepted']),
      rejected: _parseStringList(json['rejected']),

      // Default status if not available
      applicationStatus: 'Not Applied', // Default status
    );
  }
}
