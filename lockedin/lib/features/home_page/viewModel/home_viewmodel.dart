import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/post_model.dart';
import '../repository/posts/post_repository.dart';
import '../repository/posts/post_api.dart';
import 'package:flutter/foundation.dart';
import '../state/home_state.dart';

/// Provider for the HomeViewModel
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  // You can switch between PostTest and PostApi here
  // For production: return HomeViewModel(PostApi());
  return HomeViewModel(PostApi());
});

/// ViewModel for the home page
class HomeViewModel extends StateNotifier<HomeState> {
  final PostRepository repository;

  /// Constructor
  HomeViewModel(this.repository) : super(HomeState.initial()) {
    fetchHomeFeed();
  }

  /// Fetch posts for the home feed
  Future<void> fetchHomeFeed() async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);
      
      // Fetch posts from repository
      final posts = await repository.fetchHomeFeed();
      
      // Update state with fetched posts
      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Refresh feed data
  Future<void> refreshFeed() async {
    await fetchHomeFeed();
  }

  
  /// Save post for later reading using post ID

Future<bool> savePostById(String postId) async {
  try {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    
    // Call repository method
    final success = await repository.savePostById(postId);
    
    // Update state after operation
    state = state.copyWith(
      isLoading: false,
    );
    
    return success;
  } catch (e) {
    // Handle errors
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
    return false;
  }
}

   /// Toggle like status for a post
        Future<bool> toggleLike(String postId) async {
      try {
        // Find the current post
        final postIndex = state.posts.indexWhere((post) => post.id == postId);
        if (postIndex == -1) return false;
        
        final post = state.posts[postIndex];
        final currentlyLiked = post.isLiked;
        
        // Call the appropriate API method
        bool success;
        if (currentlyLiked) {
          success = await repository.unlikePost(postId); // Unlike
        } else {
          success = await repository.likePost(postId); // Like
        }
        
        if (success) {
          // Create a new list with the updated post
          final updatedPosts = List<PostModel>.from(state.posts);
          final updatedPost = post.copyWith(
            isLiked: !currentlyLiked,
            likes: currentlyLiked ? post.likes - 1 : post.likes + 1,
          );
          
          // Replace the old post with the updated one
          updatedPosts[postIndex] = updatedPost;
          
          // Update the state with the new list
          state = state.copyWith(posts: updatedPosts);
          return true;
        }
        
        return false;
      } catch (e) {
        debugPrint('Error in toggleLike: $e');
        rethrow;
      }
    }

}