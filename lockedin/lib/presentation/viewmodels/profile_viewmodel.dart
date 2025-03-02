import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/data/models/user_model.dart';
import 'package:lockedin/data/repositories/profile/profile_mock.dart';
import 'package:lockedin/data/repositories/profile/profile_repository.dart';

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<UserModel>>((ref) {
      return ProfileViewModel(ProfileMock()); // Use ProfileMock() for testing
    });

class ProfileViewModel extends StateNotifier<AsyncValue<UserModel>> {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchProfile("123"); // Example User ID
  }

  Future<void> fetchProfile(String userId) async {
    try {
      state = const AsyncValue.loading();
      final profile = await _repository.fetchUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
