import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/profile/service/edit_cover_photo_service.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';

final editCoverPhotoProvider =
    StateNotifierProvider<EditCoverPhotoViewModel, AsyncValue<void>>((ref) {
      return EditCoverPhotoViewModel(ref);
    });

class EditCoverPhotoViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  EditCoverPhotoViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<bool> updateCoverPhoto(File photoFile, BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final response = await CoverPhotoService.updateCoverPhoto(photoFile);

      if (response.statusCode == 200) {
        await ref.read(profileViewModelProvider).fetchUser(context);
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to update cover photo: ${response.body}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> deleteCoverPhoto(BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final response = await CoverPhotoService.deleteCoverPhoto();

      if (response.statusCode == 200) {
        await ref.read(profileViewModelProvider).fetchUser(context);
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to delete cover photo: ${response.body}');
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
