class Job {
  final String id;
  final String title;
  final String workplaceType;
  final String jobLocation;
  final String industry;
  final String jobType;
  final int applicants;
  final int accepted;
  final int rejected;
  final bool isActive;
  final String companyName;
  final String companyLogo;

  Job({
    required this.id,
    required this.title,
    required this.workplaceType,
    required this.jobLocation,
    required this.jobType,
    required this.industry,
    required this.applicants,
    required this.accepted,
    required this.rejected,
    required this.isActive,
    required this.companyName,
    required this.companyLogo,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Handle the case where companyId might be null
    Map<String, dynamic> companyData =
        json['companyId'] is Map
            ? json['companyId'] as Map<String, dynamic>
            : {};

    return Job(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      workplaceType: json['workplaceType'] ?? '',
      jobLocation: json['jobLocation'] ?? '',
      jobType: json['jobType'] ?? '',
      industry: json['industry'] ?? '',
      applicants:
          json['applicants'] != null ? (json['applicants'] as List).length : 0,
      accepted:
          json['accepted'] != null ? (json['accepted'] as List).length : 0,
      rejected:
          json['rejected'] != null ? (json['rejected'] as List).length : 0,
      isActive: json['isActive'] ?? false,
      companyName: companyData['name'] ?? '',
      companyLogo: companyData['logo'] ?? '',
    );
  }
}
