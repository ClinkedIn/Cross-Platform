import 'package:lockedin/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> fetchUserProfile(String userId);
}
