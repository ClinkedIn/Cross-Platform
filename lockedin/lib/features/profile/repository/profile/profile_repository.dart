import 'package:lockedin/features/profile/model/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> fetchUserProfile(String userId);
}
