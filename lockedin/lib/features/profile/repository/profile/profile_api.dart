import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/profile/profile_repository.dart';

class ProfileApi extends ProfileRepository {
  @override
  Future<UserModel> fetchUserProfile(String userId) {
    // TODO: implement fetchUserProfile
    throw UnimplementedError();
  }
}
