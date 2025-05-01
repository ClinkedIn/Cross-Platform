import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/post_model.dart';
import '../repository/posts/post_repository.dart';
import '../repository/posts/post_api.dart';
import 'package:flutter/foundation.dart';
import '../state/home_state.dart';

/// Provider for the HomeViewModel
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
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
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      // Handle errors
      state = state.copyWith(isLoading: false, error: e.toString());
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
      state = state.copyWith(isLoading: false);

      return success;
    } catch (e) {
      // Handle errors
      state = state.copyWith(isLoading: false, error: e.toString());
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

  /// Toggle repost for a post
  Future<bool> toggleRepost(String postId, {String? description}) async {
    try {
      // Find the current post
      final postIndex = state.posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return false;

      final post = state.posts[postIndex];

      // Check if the post is already reposted
      final bool isCurrentlyReposted = post.isRepost;
      bool success;

      if (isCurrentlyReposted && post.repostId != null) {
        // Delete the repost
        success = await repository.deleteRepost(post.repostId!);
      } else {
        // Create a new repost
        success = await repository.createRepost(
          postId,
          description: description,
        );
      }

      if (success) {
        // For proper UI update, ideally we should refresh the feed
        // But for immediate feedback, we can update the local state
        final updatedPosts = List<PostModel>.from(state.posts);

        // Update the repost count and status
        final updatedPost = post.copyWith(
          isRepost: !isCurrentlyReposted,
          reposts: isCurrentlyReposted ? post.reposts - 1 : post.reposts + 1,
        );

        // Replace the old post with the updated one
        updatedPosts[postIndex] = updatedPost;

        // Update the state with the new list
        state = state.copyWith(posts: updatedPosts);

        // For the best experience, refresh the feed after a successful toggle
        // to get the actual updated data from the server
        // fetchHomeFeed();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error in toggleRepost: $e');
      rethrow;
    }
  }

    /// Delete a post
      Future<bool> deletePost(String postId) async {
          try {
            // Find the post first to double-check ownership
            final postIndex = state.posts.indexWhere((post) => post.id == postId);
            if (postIndex == -1) throw Exception('Post not found');
            
            final post = state.posts[postIndex];
            if (!post.isMine) throw Exception('You can only delete your own posts');
            
            state = state.copyWith(isLoading: true, error: null);
            final success = await repository.deletePost(postId);
            
            if (success) {
              // Remove the post from the list
              final updatedPosts = List<PostModel>.from(state.posts)..removeAt(postIndex);
              state = state.copyWith(posts: updatedPosts, isLoading: false);
              return true;
            } else {
              state = state.copyWith(isLoading: false);
              return false;
            }
          } catch (e) {
            debugPrint('Error in deletePost: $e');
            state = state.copyWith(isLoading: false, error: e.toString());
            rethrow;
          }
        }
      /// Edit a post
      Future<bool> editPost(String postId, String content) async {
        try {
          // Find the post index
          final postIndex = state.posts.indexWhere((post) => post.id == postId);
          if (postIndex == -1) return false;
          
          // Set loading state
          state = state.copyWith(isLoading: true, error: null);
          
          // Call repository method
          final success = await repository.editPost(postId, content: content);
          
          if (success) {
            // Update the post in the list
            final updatedPosts = List<PostModel>.from(state.posts);
            final updatedPost = updatedPosts[postIndex].copyWith(
              content: content,
              isEdited: true,
            );
            
            // Replace the old post with the updated one
            updatedPosts[postIndex] = updatedPost;
            
            // Update state
            state = state.copyWith(posts: updatedPosts, isLoading: false);
            return true;
          }
          
          // Reset loading state if unsuccessful
          state = state.copyWith(isLoading: false);
          return false;
        } catch (e) {
          debugPrint('Error in editPost: $e');
          state = state.copyWith(isLoading: false, error: e.toString());
          rethrow;
        }
      }
      
      /// Report a post for policy violations
      Future<bool> reportPost(String postId, String policyViolation, {String? dontWantToSee}) async {
        try {
          // Set loading state (optional)
          state = state.copyWith(isLoading: true, error: null);
          
          // Call repository method
          final success = await repository.reportPost(postId, policyViolation, dontWantToSee: dontWantToSee);
          
          // Update state after operation
          state = state.copyWith(isLoading: false);
          
          return success;
        } catch (e) {
          debugPrint('Error reporting post: $e');
          state = state.copyWith(isLoading: false, error: e.toString());
          rethrow;
        }
      }
      /// get the post likes
      Future<Map<String, dynamic>> getPostLikes(String postId, {int page = 1}) async {
        try {
          final likesData = await repository.getPostLikes(postId, page: page);
          
          // // Filter to only show 'like' type reactions
          // if (likesData.containsKey('impressions') && likesData['impressions'] is List) {
          //   final allImpressions = likesData['impressions'] as List;
          //   final likesOnly = allImpressions.where((impression) => 
          //     impression['type'] == null || 
          //     impression['type'] == 'like'
          //   ).toList();
            
          //   // Replace the full list with filtered list
          //   likesData['impressions'] = likesOnly;
            
          //   // Update counts to only show likes
          //   if (likesData.containsKey('counts') && likesData['counts'] is Map) {
          //     final counts = likesData['counts'] as Map<String, dynamic>;
          //     likesData['counts'] = {
          //       'total': counts['like'] ?? likesOnly.length,
          //       'like': counts['like'] ?? likesOnly.length
          //     };
          //   }
          // }
          
          return likesData;
        } catch (e) {
          debugPrint('Error getting post likes: $e');
          rethrow;
        }
      }
}
