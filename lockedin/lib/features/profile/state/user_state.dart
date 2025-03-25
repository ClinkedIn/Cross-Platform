import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';

class UserState extends StateNotifier<UserModel?> {
  UserState() : super(null);

  void setUser(UserModel user) {
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserState, UserModel?>((ref) {
  return UserState();
});
