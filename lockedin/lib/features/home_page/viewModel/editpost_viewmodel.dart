import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../post/state/post_state.dart';
import '../../home_page/repository/posts/post_api.dart';
import '../../home_page/model/post_model.dart';

final editPostViewModelProvider = StateNotifierProvider.autoDispose<EditPostViewModel, PostState>((ref) {
  return EditPostViewModel(PostApi());
});

class EditPostViewModel extends StateNotifier<PostState> {
  final PostApi _postApi;
  
  EditPostViewModel(this._postApi) : super(PostState.initial());
  
  void initPostData(PostModel post) {
    state = PostState(
      content: post.content,
      attachments: null, // We don't load the original attachments for editing
      error: null,
      isSubmitting: false,
    );
  }
  
  void updateContent(String content) {
    state = state.copyWith(content: content);
  }
  
  void updateVisibility(String visibility) {
    state = state.copyWith(visibility: visibility);
  }
  
  Future<bool> submitEdit(String postId, {required String content}) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);
      
      final success = await _postApi.editPost(
        postId, 
        content: content,
      );
      
      state = state.copyWith(isSubmitting: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to edit post: $e',
      );
      return false;
    }
  }
}