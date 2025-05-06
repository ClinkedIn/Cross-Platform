class TaggedUser {
  final String userId;
  final String userType;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String? headline;
  final String? profilePicture;

  TaggedUser({
    required this.userId,
    this.userType = "User",
    required this.firstName,
    required this.lastName,
    this.companyName,
    this.headline,
    this.profilePicture,
  });

  // Full name for display
  String get fullName => '$firstName $lastName';

  // Create from JSON
  factory TaggedUser.fromJson(Map<String, dynamic> json) {
    return TaggedUser(
      userId: json['userId'] ?? json['_id'] ?? '',
      userType: json['userType'] ?? 'User',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      companyName: json['companyName'],
      headline: json['headline'],
      profilePicture: json['profilePicture'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userType": userType,
      "firstName": firstName,
      "lastName": lastName,
    };
  }
}