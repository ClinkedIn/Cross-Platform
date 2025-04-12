import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/profile/repository/profile/profile_api.dart';
import 'package:lockedin/features/profile/state/user_state.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:flutter/material.dart';

class ProfileViewModel {
  final Ref ref;

  ProfileViewModel(this.ref);

  Future<void> fetchUser(BuildContext context) async {
    try {
      final user = await ProfileService().fetchUserData();
      ref.read(userProvider.notifier).setUser(user);
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Unauthorized')) {
        TokenService.deleteCookie();

        if (context.mounted) {
          context.push("/login");
        }
      }
    }
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

  // Future<void> fetchLicenses() async {
  //   ref.read(licensesProvider.notifier).setLoading();
  //   try {
  //     final licenses = await ProfileService().fetchLicenses();
  //     ref.read(licensesProvider.notifier).setLicenses(licenses);
  //   } catch (e, stackTrace) {
  //     ref.read(licensesProvider.notifier).setError(e, stackTrace);
  //   }
  // }

  Future<void> fetchAllProfileData(BuildContext context) async {
    try {
      await fetchUser(context);
      await fetchEducation();
      await fetchExperience();
    } catch (e) {
      print('Error fetching profile data: $e');
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
