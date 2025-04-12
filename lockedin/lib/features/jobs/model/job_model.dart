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
    this.logoUrl,
    this.industry,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final company = json['company'] ?? {};

    // Debug: log the raw job data to investigate structure
    print("Raw job JSON: ${jsonEncode(json)}");

    // Attempt to extract the job ID safely
    final parsedId = json['_id'] ?? json['id'] ?? json['jobId'];
    print("Parsed job ID: $parsedId");

    return JobModel(
      id: parsedId?.toString() ?? '',
      title: json['title'] ?? 'Unknown Position',
      company: company['name'] ?? 'Unknown Company',
      location: json['jobLocation'] ?? 'Unknown Location',
      description: json['description'] ?? '',
      experienceLevel:
          json['screeningQuestions'] != null &&
                  json['screeningQuestions'].isNotEmpty
              ? json['screeningQuestions'][0]['specification'] ?? 'Unknown'
              : 'Unknown',
      salaryRange:
          'N/A', // You can update this if your API provides salary info
      isRemote: (json['workplaceType']?.toLowerCase() ?? '') == 'remote',
      logoUrl: company['logo'],
      industry: json['industry'],
    );
  }
}
