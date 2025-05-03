import 'dart:convert';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicture;
  final String headline;
  final String? currentCompany;
  final String? currentPosition;
  final int connections;
  final String connectionStatus;
  final bool isFollowing;
  final List<String>? skills;
  final String? about;
  final String? location;
  final String? phone;
  final String? website;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
    required this.headline,
    this.currentCompany,
    this.currentPosition,
    this.connections = 0,
    this.connectionStatus = 'none',
    this.isFollowing = false,
    this.skills,
    this.about,
    this.location,
    this.phone,
    this.website,
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName';

  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      headline: json['headline'] ?? json['title'] ?? '',
      currentCompany: json['currentCompany'] ?? 
                     (json['company'] is Map ? json['company']['name'] : json['company']),
      currentPosition: json['currentPosition'] ?? json['position'] ?? '',
      connections: json['connections'] ?? 0,
      connectionStatus: json['connectionStatus'] ?? 'none',
      isFollowing: json['isFollowing'] ?? false,
      skills: json['skills'] is List 
          ? List<String>.from(json['skills']) 
          : null,
      about: json['about'] ?? json['bio'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePicture': profilePicture,
      'headline': headline,
      'currentCompany': currentCompany,
      'currentPosition': currentPosition,
      'connections': connections,
      'connectionStatus': connectionStatus,
      'isFollowing': isFollowing,
      'skills': skills,
      'about': about,
      'location': location,
      'phone': phone,
      'website': website,
      'isVerified': isVerified,
    };
  }

  // Create a copy of this UserModel with some fields replaced
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
    String? headline,
    String? currentCompany,
    String? currentPosition,
    int? connections,
    String? connectionStatus,
    bool? isFollowing,
    List<String>? skills,
    String? about,
    String? location,
    String? phone,
    String? website,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      headline: headline ?? this.headline,
      currentCompany: currentCompany ?? this.currentCompany,
      currentPosition: currentPosition ?? this.currentPosition,
      connections: connections ?? this.connections,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isFollowing: isFollowing ?? this.isFollowing,
      skills: skills ?? this.skills,
      about: about ?? this.about,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // For debug purposes
  @override
  String toString() {
    return 'UserModel(id: $id, name: $firstName $lastName, email: $email)';
  }

  // Implement equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Add a convenience method to parse from JSON string
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(json.decode(jsonString));
  }

  // Add a convenience method to check if the user data is complete enough to display
  bool get isValid => id.isNotEmpty && (firstName.isNotEmpty || lastName.isNotEmpty);
}