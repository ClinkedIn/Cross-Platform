class JobModel {
  final String title;
  final String company;
  final String location;
  final String description;
  final String experienceLevel;
  final String salaryRange;
  final bool isRemote;
  final String? logoUrl;
  final String? industry; // Add this field

  JobModel({
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.experienceLevel,
    required this.salaryRange,
    required this.isRemote,
    this.logoUrl,
    this.industry, // Include it in the constructor
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final company = json['company'] ?? {};

    return JobModel(
      title: json['title'] ?? 'Unknown Position',
      company: company['name'] ?? 'Unknown Company',
      location: json['jobLocation'] ?? 'Unknown Location',
      description: json['description'] ?? '',
      experienceLevel:
          json['screeningQuestions'] != null &&
                  json['screeningQuestions'].isNotEmpty
              ? json['screeningQuestions'][0]['specification'] ?? 'Unknown'
              : 'Unknown',
      salaryRange: 'N/A', // Adjust if your API includes this
      isRemote: (json['workplaceType']?.toLowerCase() ?? '') == 'remote',
      logoUrl: company['logo'],
      industry: json['industry'], // Parse industry from the response
    );
  }
}
