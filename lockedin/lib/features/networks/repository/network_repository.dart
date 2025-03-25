import 'package:lockedin/features/profile/model/user_model.dart';

abstract class NetworkRepository {
  Future<UserModel> fetchNetwork(String userId);
}
