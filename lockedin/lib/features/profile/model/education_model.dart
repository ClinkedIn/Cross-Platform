class Education {
  final String school;
  final String? degree;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final String? grade;
  final String? activities;
  final String? description;
  final List<String>? skills;
  final String? media;

  Education({
    required this.school,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
    this.activities,
    this.description,
    this.skills,
    this.media,
  });

  Map<String, dynamic> toJson() {
    return {
      'school': school,
      if (degree != null) 'degree': degree,
      if (fieldOfStudy != null) 'fieldOfStudy': fieldOfStudy,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (grade != null) 'grade': grade,
      if (activities != null) 'activities': activities,
      if (description != null) 'description': description,
      if (skills != null) 'skills': skills,
      if (media != null) 'media': media,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'] ?? '',
      degree: json['degree'],
      fieldOfStudy: json['fieldOfStudy'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      grade: json['grade'],
      activities: json['activities'],
      description: json['description'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      media: json['media'],
    );
  }
}
