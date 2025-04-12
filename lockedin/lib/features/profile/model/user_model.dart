class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicture;
  final String coverPicture;
  final String resume;
  final String bio;
  final String location;
  final String lastJobTitle;
  final String industry;
  final String mainEducation;
  final String profilePrivacySettings;
  final List<WorkExperience> workExperience;
  final List<Skill> skills;
  final List<Educationn> education;
  final List<FollowEntity> following;
  final List<FollowEntity> followers;
  final List<String> connectionList;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
    required this.coverPicture,
    this.resume = "",
    this.bio = "",
    this.location = "Unknown",
    this.lastJobTitle = "",
    this.industry = "Unknown",
    this.mainEducation = "Unknown",
    this.profilePrivacySettings = "public",
    this.workExperience = const [],
    this.skills = const [],
    this.education = const [],
    this.following = const [],
    this.followers = const [],
    this.connectionList = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? "Unknown",
      firstName: json['firstName'] ?? "Unknown",
      lastName: json['lastName'] ?? "Unknown",
      email: json['email'] ?? "Unknown",
      profilePicture: json['profilePicture'] ?? "",
      coverPicture:
          json['coverPicture'] ?? "assets/images/default_cover_photo.jpeg",
      resume: json['resume'] ?? "",
      bio: json['about']["description"] ?? "",
      location: json['location'] ?? "Unknown",
      lastJobTitle: json['lastJobTitle'] ?? "",
      industry: json['industry'] ?? "Unknown",
      mainEducation: json['mainEducation'] ?? "Unknown",
      profilePrivacySettings: json['profilePrivacySettings'] ?? "public",
      workExperience:
          (json['workExperience'] as List?)
              ?.map((e) => WorkExperience.fromJson(e))
              .toList() ??
          [],
      skills:
          (json['skills'] as List?)?.map((e) => Skill.fromJson(e)).toList() ??
          [],
      education:
          (json['education'] as List?)
              ?.map((e) => Educationn.fromJson(e))
              .toList() ??
          [],
      following:
          (json['following'] as List?)
              ?.map((e) => FollowEntity.fromJson(e))
              .toList() ??
          [],
      followers:
          (json['followers'] as List?)
              ?.map((e) => FollowEntity.fromJson(e))
              .toList() ??
          [],
      connectionList: List<String>.from(json['connectionList'] ?? []),
    );
  }
}

class WorkExperience {
  final String jobTitle;
  final String companyName;
  final String fromDate;
  final String toDate;
  final String employmentType;
  final String location;
  final String locationType;
  final String description;
  final List<String> skills;

  WorkExperience({
    required this.jobTitle,
    required this.companyName,
    required this.fromDate,
    required this.toDate,
    required this.employmentType,
    required this.location,
    required this.locationType,
    required this.description,
    required this.skills,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      jobTitle: json['jobTitle'] ?? "Unknown",
      companyName: json['companyName'] ?? "Unknown",
      fromDate: json['fromDate'] ?? "",
      toDate: json['toDate'] ?? "",
      employmentType: json['employmentType'] ?? "Unknown",
      location: json['location'] ?? "Unknown",
      locationType: json['locationType'] ?? "Unknown",
      description: json['description'] ?? "",
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class Skill {
  final String skillName;
  final List<String> endorsements;

  Skill({required this.skillName, required this.endorsements});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      skillName: json['skillName'] ?? "Unknown",
      endorsements: List<String>.from(json['endorsements'] ?? []),
    );
  }
}

class Educationn {
  final String school;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String grade;
  final String description;
  final List<String> skills;

  Educationn({
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    required this.grade,
    required this.description,
    required this.skills,
  });

  factory Educationn.fromJson(Map<String, dynamic> json) {
    return Educationn(
      school: json['school'] ?? "Unknown",
      degree: json['degree'] ?? "Unknown",
      fieldOfStudy: json['fieldOfStudy'] ?? "Unknown",
      startDate: json['startDate'] ?? "",
      endDate: json['endDate'] ?? "",
      grade: json['grade'] ?? "Unknown",
      description: json['description'] ?? "",
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class FollowEntity {
  final String entity;
  final String entityType;
  final String followedAt;

  FollowEntity({
    required this.entity,
    required this.entityType,
    required this.followedAt,
  });

  factory FollowEntity.fromJson(Map<String, dynamic> json) {
    return FollowEntity(
      entity: json['entity'] ?? "Unknown",
      entityType: json['entityType'] ?? "Unknown",
      followedAt: json['followedAt'] ?? "",
    );
  }
}
