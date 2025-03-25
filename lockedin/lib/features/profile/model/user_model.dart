class UserModel {
  final String id;
  final String name;
  final String profilePicture;
  final String headline;
  final String location;
  final int connections;
  final int followers;
  final List<String> experience;
  final String about;
  final String coverPicture;

  UserModel({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.headline,
    required this.location,
    required this.connections,
    required this.followers,
    required this.experience,
    required this.about,
    required this.coverPicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      profilePicture: json['profilePicture'],
      headline: json['headline'],
      location: json['location'],
      connections: json['connections'],
      followers: json['followers'],
      experience: List<String>.from(json['experience']),
      about: json['about'],
      coverPicture: json['coverPicture'],
    );
  }
}

//Update User Model
class UpdateUserModel {
  final String firstName;
  final String lastName;
  final String bio;
  final String location;
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<String> skills;

  UpdateUserModel({
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.location,
    required this.workExperience,
    required this.education,
    required this.skills,
  });

  // Factory method for JSON parsing
  factory UpdateUserModel.fromJson(Map<String, dynamic> json) {
    return UpdateUserModel(
      firstName: json["firstName"],
      lastName: json["lastName"],
      bio: json["bio"],
      location: json["location"],
      workExperience: (json["workExperience"] as List)
          .map((item) => WorkExperience.fromJson(item))
          .toList(),
      education: (json["education"] as List)
          .map((item) => Education.fromJson(item))
          .toList(),
      skills: List<String>.from(json["skills"]),
    );
  }

  // Method to convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "bio": bio,
      "location": location,
      "workExperience": workExperience.map((item) => item.toJson()).toList(),
      "education": education.map((item) => item.toJson()).toList(),
      "skills": skills,
    };
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
      jobTitle: json["jobTitle"],
      companyName: json["companyName"],
      from: json["from"],
      to: json["to"],
      employmentType: json["employmentType"],
      location: json["location"],
      locationType: json["locationType"],
      description: json["description"],
      jobSource: json["jobSource"],
      skills: List<String>.from(json["skills"]),
      media: json["media"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "jobTitle": jobTitle,
      "companyName": companyName,
      "from": from,
      "to": to,
      "employmentType": employmentType,
      "location": location,
      "locationType": locationType,
      "description": description,
      "jobSource": jobSource,
      "skills": skills,
      "media": media,
    };
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
      school: json["school"],
      degree: json["degree"],
      fieldOfStudy: json["fieldOfStudy"],
      startDate: json["startDate"],
      endDate: json["endDate"],
      grade: json["grade"],
      activitiesAndSocieties: json["activitiesAndSocieties"],
      description: json["description"],
      skills: List<String>.from(json["skills"]),
      media: json["media"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "school": school,
      "degree": degree,
      "fieldOfStudy": fieldOfStudy,
      "startDate": startDate,
      "endDate": endDate,
      "grade": grade,
      "activitiesAndSocieties": activitiesAndSocieties,
      "description": description,
      "skills": skills,
      "media": media,
    };
  }
}
