import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/repository/profile/profile_api.dart';
import 'package:lockedin/features/profile/state/user_state.dart';

class ProfileViewModel {
  final Ref ref;

  ProfileViewModel(this.ref);

  Future<void> fetchUser() async {
    final user = await ProfileService().fetchUserData();
    ref.read(userProvider.notifier).setUser(user);
  }
}

final profileViewModelProvider = Provider((ref) => ProfileViewModel(ref));
