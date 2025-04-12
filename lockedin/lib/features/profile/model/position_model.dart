class Position {
  final String jobTitle;
  final String companyName;
  final String? fromDate;
  final String? toDate;
  final bool currentlyWorking;
  final String? employmentType;
  final String? location;
  final String? locationType;
  final String? description;
  final String? foundVia;
  final List<String>? skills;
  final String? media;

  Position({
    required this.jobTitle,
    required this.companyName,
    this.fromDate,
    this.toDate,
    required this.currentlyWorking,
    this.employmentType,
    this.location,
    this.locationType,
    this.description,
    this.foundVia,
    this.skills,
    this.media,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'companyName': companyName,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null && !currentlyWorking) 'toDate': toDate,
      'currentlyWorking': currentlyWorking,
      if (employmentType != null) 'employmentType': employmentType,
      if (location != null) 'location': location,
      if (locationType != null) 'locationType': locationType,
      if (description != null) 'description': description,
      if (foundVia != null) 'foundVia': foundVia,
      'skills': skills ?? [], // Always send an array, even if empty
      if (media != null) 'media': media,
    };
  }
}
