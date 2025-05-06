import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../state/post_state.dart';
import '../repository/createpost_APi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart'; 
import 'dart:async';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';
import 'package:lockedin/features/home_page/repository/posts/post_api.dart';

/// Provider for the post view model
final postViewModelProvider = StateNotifierProvider.autoDispose<PostViewModel, PostState>((ref) {
  return PostViewModel();
});

/// ViewModel for managing post creation state and business logic
class PostViewModel extends StateNotifier<PostState> {
  final ImagePicker _imagePicker = ImagePicker();
  final PostApi _postApi = PostApi(); // For user search
  Timer? _debounce;

  /// Constructor
  PostViewModel() : super(PostState.initial());

    @override
  void dispose() {
      _debounce?.cancel();
      super.dispose();
  }

  /// Update post content
  void updateContent(String content,TextEditingController controller) {
    state = state.copyWith(content: content);
     _checkForMentions(content, controller);
  }
  
  /// Reset the post state to initial values
  void resetState() {
    state = PostState.initial();
    debugPrint('🔄 Post state reset to initial values');
  }
  // Method to handle mention detection
    void _checkForMentions(String text, TextEditingController controller) {
      final selection = controller.selection;
      
      if (selection.baseOffset != selection.extentOffset) {
        // If there's a selection, don't try to find mentions
        state = state.copyWith(showMentionSuggestions: false);
        return;
      }
      
      final currentPosition = selection.baseOffset;
      
      // Find the last @ before the cursor
      int lastAtIndex = -1;
      for (int i = currentPosition - 1; i >= 0; i--) {
        if (text[i] == '@') {
          lastAtIndex = i;
          break;
        } else if (text[i] == ' ' || text[i] == '\n') {
          // Stop at spaces or newlines
          break;
        }
      }
      
      if (lastAtIndex >= 0) {
        // Extract query text between @ and cursor
        final query = text.substring(lastAtIndex + 1, currentPosition);

          if (query.isNotEmpty) {
          state = state.copyWith(
            mentionStartIndex: lastAtIndex,
            mentionQuery: query,
            showMentionSuggestions: true,
          );
          
          // Debounce search to avoid too many API calls
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            searchUsers(query);
          });
          return;
        }
      }
    
    state = state.copyWith(showMentionSuggestions: false);
  }

    /// Search for users to tag
      Future<void> searchUsers(String query) async {
        if (query.length < 2) {
          state = state.copyWith(
            userSearchResults: [],
            isSearchingUsers: false,
          );
          return;
        }
        
        try {
          state = state.copyWith(isSearchingUsers: true);
          
          // Call the API to search for users
          final results = await _postApi.searchUsers(query);
          
          state = state.copyWith(
            userSearchResults: results,
            isSearchingUsers: false,
          );
        } catch (e) {
          debugPrint('Error searching users: $e');
          state = state.copyWith(
            userSearchResults: [],
            isSearchingUsers: false,
            error: 'Failed to search users: $e',
          );
        }
      }

      
  /// Handle user selection for tagging
    void onMentionSelected(TaggedUser user, TextEditingController controller) {
      final text = controller.text;
      final mentionText = "${user.firstName} ${user.lastName}";
      
      // Replace the @query with the selected username
      final newText = text.replaceRange(
        state.mentionStartIndex, 
        controller.selection.baseOffset, 
        "@$mentionText "
      );
      
      // Add the user to tagged users list if not already there
      List<TaggedUser> updatedTaggedUsers = List.from(state.taggedUsers);
      if (!updatedTaggedUsers.any((u) => u.userId == user.userId)) {
        updatedTaggedUsers.add(user);
      }
      
      // Update the text and cursor position
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: state.mentionStartIndex + mentionText.length + 2, // +2 for @ and space
        ),
      );
      
      state = state.copyWith(
        content: newText,
        taggedUsers: updatedTaggedUsers,
        showMentionSuggestions: false,
      );
    }

  /// Remove a tagged user
    void removeTaggedUser(String userId) {
      final updatedTaggedUsers = List<TaggedUser>.from(state.taggedUsers)
        ..removeWhere((u) => u.userId == userId);
      
      state = state.copyWith(taggedUsers: updatedTaggedUsers);
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

  /// Pick a video from the gallery
    Future<List<File>?> pickVideo() async {
      try {
        final pickedVideo = await _imagePicker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 5), // Limit video length to 5 minutes
        );
        
        if (pickedVideo != null) {
          final attachments = [File(pickedVideo.path)];
          state = state.copyWith(attachments: attachments, fileType: 'video');
          return attachments;
        }
        return null;
      } catch (e) {
        debugPrint('Error picking video: $e');
        state = state.copyWith(error: 'Failed to select video');
        return null;
      }
    }

  /// Remove the selected image
  void removeAttachment() {
    // Use an empty list instead of null to ensure proper state update
    state = state.copyWith(
      attachments: <File>[],  // Empty list instead of null
      fileType: null,
    );
    
    // Force UI to refresh by notifying listeners
    debugPrint('🗑️ Attachment removed');
  }

  /// Submit the post
 Future<bool> submitPost({required String content, required List<File> attachments, String visibility='anyone'}) async {
  state = state.copyWith(isSubmitting: true);
    try {
      // Include visibility in the parameters
      final repository = CreatepostApi();
        // Log tagged users for debugging
        if (state.taggedUsers.isNotEmpty) {
          debugPrint('📝 Submitting post with ${state.taggedUsers.length} tagged users');
          for (var user in state.taggedUsers) {
            debugPrint('  👤 Tagging: ${user.firstName} ${user.lastName} (${user.userId})');
          }
        }

      final success = await repository.createPost(
        content: content,
        attachments: attachments,
        visibility: visibility,
        taggedUsers: state.taggedUsers,
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


  /// Update the visibility setting for the post
  void updateVisibility(String visibility) {
    state = state.copyWith(visibility: visibility);

  }
  /// Pick a document from storage
    Future<List<File>?> pickDocument() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
        );
        
        if (result != null && result.files.single.path != null) {
          final attachments = [File(result.files.single.path!)];
          state = state.copyWith(attachments: attachments, fileType: 'document');
          return attachments;
        }
        return null;
      } catch (e) {
        debugPrint('Error picking document: $e');
        state = state.copyWith(error: 'Failed to select document');
        return null;
      }
    }
}