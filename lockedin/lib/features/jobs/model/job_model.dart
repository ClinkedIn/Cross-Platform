import 'dart:convert';

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
    final screeningQuestions = json['screeningQuestions'] as List? ?? [];

    List<Map<String, dynamic>> _mapList(dynamic list) {
      if (list is List) {
        return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
      return [];
    }

    List<String> _stringList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Defensive company object parsing
    final companyData = json['company'];
    final company =
        companyData is String
            ? jsonDecode(companyData) // If company is a string, decode it
            : companyData; // If it's already an object, use it directly

    print('Fetched company data: $company');
    print('Fetched company name: ${company?['name']}');
    print('Fetched logo URL: ${company?['logo']}');

    return JobModel(
      id: (json['_id'] ?? json['id'] ?? json['jobId'])?.toString() ?? '',
      title: json['title'] ?? 'Unknown Position',
      company: company?['name'] ?? 'Unknown Company',
      companyId: (company?['id'] ?? json['companyId'] ?? '').toString(),
      location: json['jobLocation'] ?? 'Unknown Location',
      description: json['description'] ?? '',
      experienceLevel:
          screeningQuestions.isNotEmpty
              ? (screeningQuestions.first['idealAnswer']?.toString() ??
                  'Unknown')
              : 'Unknown',
      salaryRange: json['salaryRange']?.toString() ?? 'N/A',
      isRemote:
          (json['workplaceType']?.toString().toLowerCase() ?? '') == 'remote',
      workplaceType: json['workplaceType']?.toString() ?? 'Unknown',
      logoUrl: company?['logo'],
      industry: json['industry'],
      screeningQuestions: _mapList(json['screeningQuestions']),
      applicants: _mapList(json['applicants']),
      accepted: _stringList(json['accepted']),
      rejected: _stringList(json['rejected']),
      applicationStatus: 'Not Applied',
    );
  }

  bool hasApplied(String userId) {
    return applicants.any((applicant) => applicant['userId'] == userId);
  }

  String get companyName => company;
}
