import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/education_model.dart';
import 'package:lockedin/features/profile/model/position_model.dart';

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

// final licensesProvider =
//     StateNotifierProvider<LicensesNotifier, AsyncValue<List<License>>>((ref) {
//       return LicensesNotifier();
//     });

// class LicensesNotifier extends StateNotifier<AsyncValue<List<License>>> {
//   LicensesNotifier() : super(const AsyncValue.loading());

//   void setLicenses(List<License> licenses) {
//     state = AsyncValue.data(licenses);
//   }

//   void setError(Object error, StackTrace stackTrace) {
//     state = AsyncValue.error(error, stackTrace);
//   }

//   void setLoading() {
//     state = const AsyncValue.loading();
//   }
// }
