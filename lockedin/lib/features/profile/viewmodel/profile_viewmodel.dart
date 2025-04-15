import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/profile/repository/profile/profile_api.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';

class ProfileViewModel {
  final Ref ref;

  ProfileViewModel(this.ref);

  Future<void> fetchUser() async {
    final user = await ProfileService().fetchUserData();
    ref.read(userProvider.notifier).setUser(user);
  }

  Future<void> fetchEducation() async {
    ref.read(educationProvider.notifier).setLoading();
    try {
      final education = await ProfileService().fetchEducation();
      ref.read(educationProvider.notifier).setEducation(education);
    } catch (e, stackTrace) {
      ref.read(educationProvider.notifier).setError(e, stackTrace);
    }
  }

  Future<void> fetchExperience() async {
    ref.read(experienceProvider.notifier).setLoading();
    try {
      final experience = await ProfileService().fetchExperience();
      ref.read(experienceProvider.notifier).setExperience(experience);
    } catch (e, stackTrace) {
      ref.read(experienceProvider.notifier).setError(e, stackTrace);
    }
  }

  Future<void> fetchAllProfileData() async {
    try {
      // Try to fetch user data first
      await fetchUser();

      // Only proceed with fetching additional data if user fetch was successful

      await fetchEducation();
      await fetchExperience();
    } catch (e) {
      // You can add a snackbar or other user feedback here
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}

final profileViewModelProvider = Provider((ref) => ProfileViewModel(ref));
