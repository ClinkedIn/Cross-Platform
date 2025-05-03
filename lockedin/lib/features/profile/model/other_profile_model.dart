import 'package:lockedin/features/profile/model/user_model.dart';

class OtherProfileData {
  final UserModel user;
  final bool canSendConnectionRequest;

  OtherProfileData({
    required this.user,
    required this.canSendConnectionRequest,
  });
}
