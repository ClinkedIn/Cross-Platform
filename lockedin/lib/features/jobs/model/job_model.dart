class JobModel {
  final String title;
  final String company;
  final String location;
  final String description;
  final String experienceLevel;
  final String salaryRange;
  final bool isRemote;
  final String? logoUrl;

  JobModel({
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.experienceLevel,
    required this.salaryRange,
    required this.isRemote,
    this.logoUrl,
  });
}
