class User {
  final String id;
  final String firstName;
  final String lastName;
  final String company;
  final String industry;
  final String profilePicture;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.industry,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      company: json['company'],
      industry: json['industry'],
      profilePicture: json['profilePicture'],
    );
  }
}