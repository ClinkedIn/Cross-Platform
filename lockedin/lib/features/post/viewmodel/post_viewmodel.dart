import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../state/post_state.dart';
import '../repository/createpost_APi.dart';

/// Provider for the post view model
final postViewModelProvider = StateNotifierProvider.autoDispose<PostViewModel, PostState>((ref) {
  return PostViewModel();
});

/// ViewModel for managing post creation state and business logic
class PostViewModel extends StateNotifier<PostState> {
  final ImagePicker _imagePicker = ImagePicker();

  /// Constructor
  PostViewModel() : super(PostState.initial());

  /// Update post content
  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  /// Pick an image from the gallery
  Future<List<File>?> pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedImage != null) {
        final attachments = [File(pickedImage.path)];
        state = state.copyWith(attachments: attachments);
        return attachments;
      }
        return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      state = state.copyWith(error: 'Failed to select image');
      return null;
    }
  }

  /// Remove the selected image
  void removeImage() {
    state = state.copyWith(attachments: null);
  }

  /// Submit the post
 Future<bool> submitPost({required String content, required List<File> attachments, String visibility='anyone'}) async {
  state = state.copyWith(isSubmitting: true);
    try {
      // Include visibility in the parameters
      final repository = CreatepostApi();
      final success = await repository.createPost(
        content: content,
        attachments: attachments,
        visibility: visibility,
      );
      state = state.copyWith(isSubmitting: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }
  /// Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Add this method to your PostViewModel class:

  /// Update the visibility setting for the post
  void updateVisibility(String visibility) {
    state = state.copyWith(visibility: visibility);

  }
  
}