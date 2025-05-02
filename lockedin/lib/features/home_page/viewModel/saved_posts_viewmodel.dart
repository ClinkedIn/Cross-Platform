import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/home_page/repository/posts/post_api.dart';
import 'package:lockedin/features/home_page/repository/saved_posts_api.dart';
import 'package:lockedin/features/home_page/state/saved_posts_state.dart';

// Saved posts view model
class SavedPostsViewModel {
  final SavedPostsApi _savedPostsApi;
  final PostApi _postApi;
  final SavedPostsStateNotifier _stateNotifier;

  SavedPostsViewModel(this._savedPostsApi, this._postApi, this._stateNotifier) {
    // Initial load of saved posts
    loadSavedPosts();
  }

  // Load saved posts from the API
  Future<void> loadSavedPosts() async {
    try {
      _stateNotifier.setLoading();
      final posts = await _savedPostsApi.fetchSavedPosts();
      _stateNotifier.updatePosts(posts);
    } catch (e) {
      debugPrint('Error loading saved posts: $e');
      _stateNotifier.setError('Failed to load saved posts: $e');
    }
  }

  // Refresh the saved posts list
  Future<void> refreshSavedPosts() async {
    try {
      _stateNotifier.setLoading();
      final posts = await _savedPostsApi.fetchSavedPosts();
      _stateNotifier.updatePosts(posts);
    } catch (e) {
      debugPrint('Error refreshing saved posts: $e');
      _stateNotifier.setError('Failed to refresh saved posts: $e');
    }
  }

  // Toggle like on a post
  Future<void> toggleLike(String postId) async {
    try {
      // Find the post in the state
      final state = _stateNotifier.state;
      final postIndex = state.posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      // Get the current post
      final post = state.posts[postIndex];
      
      // Toggle the like status
      if (post.isLiked) {
        await _postApi.unlikePost(postId);
      } else {
        await _postApi.likePost(postId);
      }

      // Update the post in the state
      final updatedPost = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      
      _stateNotifier.updatePost(postId, updatedPost);
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // You might want to show an error to the user here
    }
  }

  // Remove a post from saved posts
  Future<void> removeFromSaved(String postId) async {
    try {
      // Call the API to unsave the post
      await _postApi.savePostById(postId); // This should toggle the saved status
      
      // Remove the post from the state
      _stateNotifier.removePost(postId);
    } catch (e) {
      debugPrint('Error removing post from saved: $e');
      // You might want to show an error to the user here
    }
  }

  // Additional methods for other post interactions can be added here
}

// Provider for the saved posts view model
final savedPostsViewModelProvider = Provider((ref) {
  final stateNotifier = ref.watch(savedPostsStateProvider.notifier);
  return SavedPostsViewModel(
    SavedPostsApi(),
    PostApi(),
    stateNotifier,
  );
});