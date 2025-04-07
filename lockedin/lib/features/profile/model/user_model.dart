class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicture;
  final String coverPicture;
  final String resume;
  final String bio;
  final String location;
  final String lastJobTitle;
  final List<WorkExperience> workExperience;
  final List<Skill> skills;
  final List<Education> education;
  final String profilePrivacySettings;
  final String connectionRequestPrivacySetting;
  final List<String> following;
  final List<String> followers;
  final List<String> connectionList;
  final List<String> blockedUsers;
  final List<String> profileViews;
  final List<String> savedPosts;
  final List<String> savedJobs;
  final List<AppliedJob> appliedJobs;
  final List<String> jobListings;
  final String defaultMode;
  final bool isActive;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
    required this.coverPicture,
    this.resume = "",
    this.bio = "",
    this.location = "Unknown",
    this.lastJobTitle = "",
    this.workExperience = const [],
    this.skills = const [],
    this.education = const [],
    this.profilePrivacySettings = "public",
    this.connectionRequestPrivacySetting = "everyone",
    this.following = const [],
    this.followers = const [],
    this.connectionList = const [],
    this.blockedUsers = const [],
    this.profileViews = const [],
    this.savedPosts = const [],
    this.savedJobs = const [],
    this.appliedJobs = const [],
    this.jobListings = const [],
    this.defaultMode = "light",
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? "Unknown",
      lastName: json['lastName'] ?? "Unknown",
      email: json['email'] ?? "Unknown",
      profilePicture: "assets/images/default_profile_photo.png",
      coverPicture: "assets/images/default_cover_photo.jpeg",
      resume: json['resume'] ?? "",
      bio: json['bio'] ?? "",
      location: json['location'] ?? "Unknown",
      lastJobTitle: json['lastJobTitle'] ?? "",
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
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      profilePrivacySettings: json['profilePrivacySettings'] ?? "public",
      connectionRequestPrivacySetting:
          json['connectionRequestPrivacySetting'] ?? "everyone",
      following: List<String>.from(json['following'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
      connectionList: List<String>.from(json['connectionList'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      profileViews: List<String>.from(json['profileViews'] ?? []),
      savedPosts: List<String>.from(json['savedPosts'] ?? []),
      savedJobs: List<String>.from(json['savedJobs'] ?? []),
      appliedJobs:
          (json['appliedJobs'] as List?)
              ?.map((e) => AppliedJob.fromJson(e))
              .toList() ??
          [],
      jobListings: List<String>.from(json['jobListings'] ?? []),
      defaultMode: json['defaultMode'] ?? "light",
      isActive: json['isActive'] ?? true,
    );
  }
}

class WorkExperience {
  final String jobTitle;
  final String companyName;
  final String from;
  final String to;
  final String employmentType;
  final String location;
  final String locationType;
  final String description;
  final String jobSource;
  final List<String> skills;
  final String media;

  WorkExperience({
    required this.jobTitle,
    required this.companyName,
    required this.from,
    required this.to,
    required this.employmentType,
    required this.location,
    required this.locationType,
    required this.description,
    required this.jobSource,
    required this.skills,
    required this.media,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      jobTitle: json['jobTitle'] ?? "Unknown",
      companyName: json['companyName'] ?? "Unknown",
      from: json['from'] ?? "",
      to: json['to'] ?? "",
      employmentType: json['employmentType'] ?? "",
      location: json['location'] ?? "Unknown",
      locationType: json['locationType'] ?? "",
      description: json['description'] ?? "",
      jobSource: json['jobSource'] ?? "",
      skills: List<String>.from(json['skills'] ?? []),
      media: json['media'] ?? "",
    );
  }
}

class Skill {
  final String name;
  final List<String> endorsements;

  Skill({required this.name, required this.endorsements});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] ?? "Unknown",
      endorsements: List<String>.from(json['endorsements'] ?? []),
    );
  }
}

class Education {
  final String school;
  final String degree;
  final String fieldOfStudy;
  final String startDate;
  final String endDate;
  final String grade;
  final String activitiesAndSocieties;
  final String description;
  final List<String> skills;
  final String media;

  Education({
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    required this.grade,
    required this.activitiesAndSocieties,
    required this.description,
    required this.skills,
    required this.media,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'] ?? "Unknown",
      degree: json['degree'] ?? "Unknown",
      fieldOfStudy: json['fieldOfStudy'] ?? "Unknown",
      startDate: json['startDate'] ?? "",
      endDate: json['endDate'] ?? "",
      grade: json['grade'] ?? "",
      activitiesAndSocieties: json['activitiesAndSocieties'] ?? "",
      description: json['description'] ?? "",
      skills: List<String>.from(json['skills'] ?? []),
      media: json['media'] ?? "",
    );
  }
}

class AppliedJob {
  final String jobId;
  final String status;

  AppliedJob({required this.jobId, required this.status});

  factory AppliedJob.fromJson(Map<String, dynamic> json) {
    return AppliedJob(
      jobId: json['jobId'] ?? "Unknown",
      status: json['status'] ?? "pending",
    );
  }
}