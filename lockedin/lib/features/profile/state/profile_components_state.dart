import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/position_model.dart';
import 'package:lockedin/features/profile/model/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>(
  (ref) {
    return UserNotifier();
  },
);

class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  UserNotifier() : super(const AsyncValue.loading());

  void setUser(UserModel user) {
    Future.microtask(() {
      state = AsyncValue.data(user);
    });
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  void setLoading() {
    state = const AsyncValue.loading();
  }
}

final educationProvider =
    StateNotifierProvider<EducationNotifier, AsyncValue<List<Education>>>((
      ref,
    ) {
      return EducationNotifier();
    });

class EducationNotifier extends StateNotifier<AsyncValue<List<Education>>> {
  EducationNotifier() : super(const AsyncValue.loading());

  void setEducation(List<Education> education) {
    state = AsyncValue.data(education);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  void setLoading() {
    state = const AsyncValue.loading();
  }
}

final experienceProvider =
    StateNotifierProvider<ExperienceNotifier, AsyncValue<List<Position>>>((
      ref,
    ) {
      return ExperienceNotifier();
    });

class ExperienceNotifier extends StateNotifier<AsyncValue<List<Position>>> {
  ExperienceNotifier() : super(const AsyncValue.loading());

  void setExperience(List<Position> experience) {
    state = AsyncValue.data(experience);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  void setLoading() {
    state = const AsyncValue.loading();
  }
}
