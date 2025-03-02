import 'package:lockedin/data/models/user_model.dart';
import 'package:lockedin/data/repositories/profile/profile_repository.dart';
import 'dart:convert';

class ProfileApi extends ProfileRepository {
  @override
  Future<UserModel> fetchUserProfile(String userId) {
    // TODO: implement fetchUserProfile
    throw UnimplementedError();
  }
}
