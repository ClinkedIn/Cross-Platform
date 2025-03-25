import 'package:lockedin/features/profile/service/update_user_profile_service.dart';
import '../../model/user_model.dart';

class UpdateProfileApi {
  static Future updateProfileApi(Map<String, dynamic> user) async {
    UpdateUserProfileService.updateUserProfile(UpdateUserModel.fromJson(user));
  }
}
