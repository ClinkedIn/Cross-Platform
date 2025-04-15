import 'dart:convert';

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
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final companyData = json['company'] is Map ? json['company'] : null;
    final screeningQuestions = json['screeningQuestions'] as List?;

    print("Raw job JSON: ${jsonEncode(json)}");

    final workplaceTypeRaw = json['workplaceType']?.toString() ?? 'Unknown';

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
    );
  }
}
