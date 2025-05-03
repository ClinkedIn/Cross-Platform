// Updated UserModel matching the Mongoose schema

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? additionalName;
  final String? headline;
  final String? profilePicture;
  final String? coverPicture;
  final String? resume;
  final String? website;
  final ContactInfo? contactInfo;
  final About? about;
  final String? location;
  final String? lastJobTitle;
  final String? industry;
  final String? mainEducation;
  final List<Skill> skills;
  final List<Education> education;
  final List<String> certificates;
  final List<WorkExperience> workExperience;
  final List<String> companies;
  final List<String> adminInCompanies;
  final bool isSuperAdmin;
  final bool isPremium;
  final String? subscription;
  final List<String> transactions;
  final String profilePrivacySettings;
  final String connectionRequestPrivacySetting;
  final List<FollowEntity> following;
  final List<FollowEntity> followers;
  final List<String> connectionList;
  final List<String> blockedUsers;
  final List<String> profileViews;
  final List<String> savedPosts;
  final List<String> savedJobs;
  final bool isConfirmed;
  final List<String> sentConnectionRequests;
  final List<String> receivedConnectionRequests;
  final List<String> messageRequests;
  final List<ChatInfo> chats;
  // final List<String> impressions;
  final String defaultMode;
  final String? googleId;
  final List<String> fcmToken;
  final DateTime? emailVerificationOTPExpiresAt;
  final DateTime? passwordResetOTPExpiresAt;
  final DateTime? notificationPauseExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.additionalName,
    this.headline,
    this.profilePicture,
    this.coverPicture,
    this.resume,
    this.website,
    this.contactInfo,
    this.about,
    this.location,
    this.lastJobTitle,
    this.industry,
    this.mainEducation,
    this.skills = const [],
    this.education = const [],
    this.certificates = const [],
    this.workExperience = const [],
    this.companies = const [],
    this.adminInCompanies = const [],
    this.isSuperAdmin = false,
    this.isPremium = false,
    this.subscription,
    this.transactions = const [],
    this.profilePrivacySettings = "public",
    this.connectionRequestPrivacySetting = "everyone",
    this.following = const [],
    this.followers = const [],
    this.connectionList = const [],
    this.blockedUsers = const [],
    this.profileViews = const [],
    this.savedPosts = const [],
    this.savedJobs = const [],
    this.isConfirmed = false,
    this.sentConnectionRequests = const [],
    this.receivedConnectionRequests = const [],
    this.messageRequests = const [],
    this.chats = const [],
    this.defaultMode = "light",
    this.googleId,
    this.fcmToken = const [],
    this.emailVerificationOTPExpiresAt,
    this.passwordResetOTPExpiresAt,
    this.notificationPauseExpiresAt,
    // this.impressions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      additionalName: json['additionalName'],
      headline: json['headline'],
      profilePicture: json['profilePicture'],
      coverPicture: json['coverPicture'],
      // impressions: json['impressions'],
      resume: json['resume'],
      website: json['website'],
      contactInfo:
          json['contactInfo'] != null
              ? ContactInfo.fromJson(json['contactInfo'])
              : null,
      about:
          json['about'] != null
              ? About(
                description: json['about']['description'],
                skills: List<String>.from(json['about']['skills'] ?? []),
              )
              : null,
      location: json['location'],
      lastJobTitle: json['lastJobTitle'],
      industry: json['industry'],
      mainEducation: json['mainEducation'],
      skills:
          (json['skills'] as List?)
              ?.map(
                (e) => Skill(
                  skillName: e['skillName'],
                  endorsements: List<String>.from(e['endorsements'] ?? []),
                  education: List<int>.from(e['education'] ?? []),
                  experience: List<int>.from(e['experience'] ?? []),
                ),
              )
              .toList() ??
          [],
      education:
          (json['education'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      certificates: List<String>.from(json['certificates'] ?? []),
      workExperience:
          (json['workExperience'] as List?)
              ?.map(
                (e) => WorkExperience(
                  jobTitle: e['jobTitle'],
                  companyName: e['companyName'],
                  fromDate: e['fromDate'],
                  toDate: e['toDate'],
                  currentlyWorking: e['currentlyWorking'],
                  employmentType: e['employmentType'],
                  location: e['location'],
                  locationType: e['locationType'],
                  description: e['description'],
                  foundVia: e['foundVia'],
                  skills: List<String>.from(e['skills'] ?? []),
                  media: e['media'],
                ),
              )
              .toList() ??
          [],
      companies: List<String>.from(json['companies'] ?? []),
      adminInCompanies: List<String>.from(json['adminInCompanies'] ?? []),
      isSuperAdmin: json['isSuperAdmin'] ?? false,
      isPremium: json['isPremium'] ?? false,
      subscription: json['subscription'],
      transactions: List<String>.from(json['transactions'] ?? []),
      profilePrivacySettings: json['profilePrivacySettings'] ?? 'public',
      connectionRequestPrivacySetting:
          json['connectionRequestPrivacySetting'] ?? 'everyone',
      following:
          (json['following'] as List?)
              ?.map(
                (e) => FollowEntity(
                  entity: e['entity'],
                  entityType: e['entityType'],
                  followedAt: e['followedAt'],
                ),
              )
              .toList() ??
          [],
      followers:
          (json['followers'] as List?)
              ?.map(
                (e) => FollowEntity(
                  entity: e['entity'],
                  entityType: e['entityType'],
                  followedAt: e['followedAt'],
                ),
              )
              .toList() ??
          [],
      connectionList: List<String>.from(json['connectionList'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      profileViews: List<String>.from(json['profileViews'] ?? []),
      savedPosts: List<String>.from(json['savedPosts'] ?? []),
      savedJobs: List<String>.from(json['savedJobs'] ?? []),
      isConfirmed: json['isConfirmed'] ?? false,
      sentConnectionRequests: List<String>.from(
        json['sentConnectionRequests'] ?? [],
      ),
      receivedConnectionRequests: List<String>.from(
        json['receivedConnectionRequests'] ?? [],
      ),
      messageRequests: List<String>.from(json['messageRequests'] ?? []),
      chats:
          (json['chats'] as List?)
              ?.map(
                (e) => ChatInfo(
                  chatId: e['chatId'],
                  chatType: e['chatType'],
                  unreadCount: e['unreadCount'] ?? 0,
                  lastReadAt:
                      e['lastReadAt'] != null
                          ? DateTime.parse(e['lastReadAt'])
                          : null,
                  muted: e['muted'] ?? false,
                  archived: e['archived'] ?? false,
                  starred: e['starred'] ?? false,
                ),
              )
              .toList() ??
          [],
      defaultMode: json['defaultMode'] ?? 'light',
      googleId: json['googleId'],
      fcmToken: List<String>.from(json['fcmToken'] ?? []),
      emailVerificationOTPExpiresAt:
          json['emailVerificationOTPExpiresAt'] != null
              ? DateTime.parse(json['emailVerificationOTPExpiresAt'])
              : null,
      passwordResetOTPExpiresAt:
          json['passwordResetOTPExpiresAt'] != null
              ? DateTime.parse(json['passwordResetOTPExpiresAt'])
              : null,
      notificationPauseExpiresAt:
          json['notificationPauseExpiresAt'] != null
              ? DateTime.parse(json['notificationPauseExpiresAt'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (additionalName != null) 'additionalName': additionalName,
      if (headline != null) 'headline': headline,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (coverPicture != null) 'coverPicture': coverPicture,
      if (resume != null) 'resume': resume,
      if (website != null) 'website': website,
      if (contactInfo != null) 'contactInfo': contactInfo!.toJson(),
      if (about != null)
        'about': {
          if (about!.description != null) 'description': about!.description,
          'skills': about!.skills,
        },
      if (location != null) 'location': location,
      if (lastJobTitle != null) 'lastJobTitle': lastJobTitle,
      if (industry != null) 'industry': industry,
      if (mainEducation != null) 'mainEducation': mainEducation,
      'skills':
          skills
              .map(
                (e) => {
                  'skillName': e.skillName,
                  'endorsements': e.endorsements,
                  'education': e.education,
                  'experience': e.experience,
                },
              )
              .toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'certificates': certificates,
      'workExperience': workExperience.map((e) => e.toJson()).toList(),
      'companies': companies,
      'adminInCompanies': adminInCompanies,
      'isSuperAdmin': isSuperAdmin,
      'isPremium': isPremium,
      if (subscription != null) 'subscription': subscription,
      'transactions': transactions,
      'profilePrivacySettings': profilePrivacySettings,
      'connectionRequestPrivacySetting': connectionRequestPrivacySetting,
      'connectionList': connectionList,
      'isConfirmed': isConfirmed,
      'defaultMode': defaultMode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static UserModel empty() {
    return UserModel(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class ContactInfo {
  final String phone;
  final String phoneType;
  final String address;
  final Birthday birthDay;
  final ContactWebsite? website;

  ContactInfo({
    required this.phone,
    required this.phoneType,
    required this.address,
    required this.birthDay,
    this.website,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] ?? '',
      phoneType: json['phoneType'] ?? 'Home',
      address: json['address'] ?? '',
      birthDay: Birthday(
        day: json['birthDay']['day'] ?? 1,
        month: json['birthDay']['month'] ?? 'January',
      ),
      website:
          json['website'] != null
              ? ContactWebsite(
                url: json['website']['url'],
                type: json['website']['type'],
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'phoneType': phoneType,
      'address': address,
      'birthDay': {'day': birthDay.day, 'month': birthDay.month},
      if (website != null)
        'website': {'url': website!.url, 'type': website!.type},
    };
  }
}

class Birthday {
  final int day;
  final String month;
  Birthday({required this.day, required this.month});
}

class ContactWebsite {
  final String? url;
  final String? type;
  ContactWebsite({this.url, this.type});
}

class About {
  final String? description;
  final List<String> skills;

  About({this.description, this.skills = const []});
}

class Skill {
  final String skillName;
  final List<String> endorsements;
  final List<int> education;
  final List<int> experience;

  Skill({
    required this.skillName,
    this.endorsements = const [],
    this.education = const [],
    this.experience = const [],
  });
}

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

class WorkExperience {
  final String jobTitle;
  final String companyName;
  final String fromDate;
  final String? toDate;
  final bool? currentlyWorking;
  final String employmentType;
  final String? location;
  final String? locationType;
  final String? description;
  final String? foundVia;
  final List<String> skills;
  final String? media;

  WorkExperience({
    required this.jobTitle,
    required this.companyName,
    required this.fromDate,
    this.toDate,
    this.currentlyWorking,
    required this.employmentType,
    this.location,
    this.locationType,
    this.description,
    this.foundVia,
    this.skills = const [],
    this.media,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'companyName': companyName,
      'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
      if (currentlyWorking != null) 'currentlyWorking': currentlyWorking,
      'employmentType': employmentType,
      if (location != null) 'location': location,
      if (locationType != null) 'locationType': locationType,
      if (description != null) 'description': description,
      if (foundVia != null) 'foundVia': foundVia,
      'skills': skills,
      if (media != null) 'media': media,
    };
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
}

class ChatInfo {
  final String chatId;
  final String chatType;
  final int unreadCount;
  final DateTime? lastReadAt;
  final bool muted;
  final bool archived;
  final bool starred;

  ChatInfo({
    required this.chatId,
    required this.chatType,
    this.unreadCount = 0,
    this.lastReadAt,
    this.muted = false,
    this.archived = false,
    this.starred = false,
  });
}
