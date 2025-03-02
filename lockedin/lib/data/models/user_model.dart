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
