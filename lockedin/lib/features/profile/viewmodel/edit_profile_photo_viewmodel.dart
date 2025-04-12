import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/profile/service/edit_profile_photo_service.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';

final editProfilePhotoProvider =
    StateNotifierProvider<EditProfilePhotoViewModel, AsyncValue<void>>((ref) {
      return EditProfilePhotoViewModel(ref);
    });

class EditProfilePhotoViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  EditProfilePhotoViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<bool> updateProfilePhoto(File photoFile, BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final response = await ProfilePhotoService.updateProfilePhoto(photoFile);

      if (response.statusCode == 200) {
        // Refresh user data to get updated profile photo
        await ref.read(profileViewModelProvider).fetchUser(context);
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to update profile photo: ${response.body}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> deleteProfilePhoto(BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final response = await ProfilePhotoService.deleteProfilePhoto();

      if (response.statusCode == 200) {
        // Refresh user data to get updated profile state
        await ref.read(profileViewModelProvider).fetchUser(context);
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to delete profile photo: ${response.body}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
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
