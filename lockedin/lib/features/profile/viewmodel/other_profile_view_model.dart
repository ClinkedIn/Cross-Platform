import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/other_profile_repository.dart';

final otherProfileViewModelProvider = StateNotifierProvider.autoDispose<
  OtherProfileViewModel,
  AsyncValue<UserModel>
>((ref) => OtherProfileViewModel());

class OtherProfileViewModel extends StateNotifier<AsyncValue<UserModel>> {
  final OtherProfileRepository _repository = OtherProfileRepository();

  OtherProfileViewModel() : super(const AsyncLoading());

  Future<void> fetchUserProfile(String userId) async {
    try {
      final user = await _repository.getUserProfile(userId);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}
