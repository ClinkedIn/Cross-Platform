import 'package:lockedin/data/models/user_model.dart';
import 'package:lockedin/data/repositories/profile/profile_repository.dart';

class ProfileMock extends ProfileRepository {
  @override
  Future<UserModel> fetchUserProfile(String userId) async {
    return UserModel(
      id: userId,
      name: "Omar Refaat",
      profilePicture: "assets/images/download.png",
      headline: "Software Engineer | Flutter Developer",
      location: "Cairo, Egypt",
      connections: 500,
      followers: 1200,
      experience: ["Software Engineer at Google", "Intern at Microsoft"],
      about: "Passionate about software engineering and mobile development.",
      coverPicture: "assets/images/download.jpeg",
    );
  }
}
