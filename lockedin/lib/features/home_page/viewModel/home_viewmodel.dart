import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/auth_service.dart';
import '../model/post_model.dart';
import '../repository/posts/post_repository.dart';
import '../repository/posts/post_api.dart';
import 'package:flutter/foundation.dart';
import '../state/home_state.dart';
import '../model/taggeduser_model.dart';

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

      // Fetch posts from repository (now with pagination)
      final result = await repository.fetchHomeFeed(page: 1, limit: state.limit);
      final List<PostModel> posts = result['posts'];
      final Map<String, dynamic> pagination = result['pagination'];

      // Update state with fetched posts and pagination info
      state = state.copyWith(
        posts: posts, 
        isLoading: false,
        currentPage: pagination['page'] ?? 1,
        totalPages: pagination['pages'] ?? 1,
        totalPosts: pagination['total'] ?? 0,
        hasNextPage: pagination['hasNextPage'] ?? false,
        hasPrevPage: pagination['hasPrevPage'] ?? false,
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh feed data (reset to page 1)
  Future<void> refreshFeed() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
      );

      // Fetch first page of posts
      final result = await repository.fetchHomeFeed(page: 1, limit: state.limit);
      final List<PostModel> posts = result['posts'];
      final Map<String, dynamic> pagination = result['pagination'];

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        currentPage: pagination['page'] ?? 1,
        totalPages: pagination['pages'] ?? 1,
        totalPosts: pagination['total'] ?? 0,
        hasNextPage: pagination['hasNextPage'] ?? false,
        hasPrevPage: pagination['hasPrevPage'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more posts (next page)
  Future<void> loadMorePosts() async {
    // Don't load more if already loading or no more pages
    if (state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await repository.fetchHomeFeed(
        page: nextPage, 
        limit: state.limit
      );
      
      final List<PostModel> newPosts = result['posts'];
      final Map<String, dynamic> pagination = result['pagination'];

      // Combine existing posts with new posts
      final updatedPosts = [...state.posts, ...newPosts];

      state = state.copyWith(
        posts: updatedPosts,
        isLoadingMore: false,
        currentPage: pagination['page'] ?? nextPage,
        totalPages: pagination['pages'] ?? state.totalPages,
        totalPosts: pagination['total'] ?? state.totalPosts,
        hasNextPage: pagination['hasNextPage'] ?? false,
        hasPrevPage: pagination['hasPrevPage'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle save status for a post
  Future<bool> toggleSaveForLater(String postId) async {
    try {
      // Find the post in the current state
      final index = state.posts.indexWhere((post) => post.id == postId);
      if (index == -1) {
        // Post not found in the current state
        return false;
      }

      final post = state.posts[index];
      final isCurrentlySaved = post.isSaved;

      // Optimistically update UI
      final updatedPost = post.copyWith(
        isSaved: !(isCurrentlySaved ?? false),
      );
      final updatedPosts = List<PostModel>.from(state.posts);
      updatedPosts[index] = updatedPost;
      state = state.copyWith(posts: updatedPosts);

      // Make the API call based on the new state
      bool success;
      if (!(isCurrentlySaved ?? false)) {
        // Save the post
        try {
          success = await repository.savePostById(postId);
        } catch (e) {
          // Check for "already saved" error
          if (e.toString().contains("already saved this post")) {
            // This is fine, the server state matches our optimistic update
            return true;
          }
          // Rethrow other errors
          rethrow;
        }
      } else {
        // Unsave the post
        try { 
          success = await repository.unsavePostById(postId);
        } catch (e) {
          // Check for "not saved" error
          if (e.toString().contains("not saved this post")) {
            // This is fine, the server state matches our optimistic update
            return true;
          }
          // Rethrow other errors
          rethrow;
        }
      }

      return success;
    } catch (e) {
      // If there was an error, revert the optimistic update
      await refreshFeed(); // Refresh to get the correct state
      debugPrint('Error in toggleSaveForLater: $e');
      throw e; // Rethrow to allow UI to handle the error
    }
  }

  /// Toggle like status for a post
  Future<bool> toggleLike(String postId) async {
    try {
      // Find the post in the current state
      final index = state.posts.indexWhere((post) => post.id == postId);
      if (index == -1) {
        // Post not found in the current state
        return false;
      }

      final post = state.posts[index];
      final isCurrentlyLiked = post.isLiked;

      // Optimistically update UI
      final updatedPost = post.copyWith(
        isLiked: !isCurrentlyLiked,
        likes: isCurrentlyLiked ? post.likes - 1 : post.likes + 1,
      );
      final updatedPosts = List<PostModel>.from(state.posts);
      updatedPosts[index] = updatedPost;
      state = state.copyWith(posts: updatedPosts);

      // Make the API call based on the new state
      bool success;
      if (!isCurrentlyLiked) {
        // Like the post
        try {
          success = await repository.likePost(postId);
        } catch (e) {
          // Check for "already liked" error
          if (e.toString().contains("already liked this post")) {
            // This is fine, the server state matches our optimistic update
            return true;
          }
          // Rethrow other errors
          rethrow;
        }
      } else {
        // Unlike the post
        try { 
          success = await repository.unlikePost(postId);
        } catch (e) {
          // Check for "not liked" error
          if (e.toString().contains("not liked this post")) {
            // This is fine, the server state matches our optimistic update
            return true;
          }
          // Rethrow other errors
          rethrow;
        }
      }

      return success;
    } catch (e) {
      // If there was an error, revert the optimistic update
      await refreshFeed(); // Refresh to get the correct state
      debugPrint('Error in toggleLike: $e');
      throw e; // Rethrow to allow UI to handle the error
    }
  }

  /// Toggle repost for a post
    Future<bool> toggleRepost(String postId,String user, {String? description}) async {
      try {
        // Find the current post
        final postIndex = state.posts.indexWhere((post) => post.id == postId);
        if (postIndex == -1) return false;

        final post = state.posts[postIndex];

        // Check if the post is already reposted
        final bool isCurrentlyReposted = post.isRepost;
        bool success;

        if (isCurrentlyReposted && post.reposterId == user) {
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
    // Existing implementation...
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
  Future<bool> editPost(String postId, String content, {List<TaggedUser>? taggedUsers}) async {
    // Existing implementation...
    try {
      debugPrint('📝 Editing post: $postId');
      if (taggedUsers != null && taggedUsers.isNotEmpty) {
        debugPrint('👥 With ${taggedUsers.length} tagged users');
      }
      
      // Use the updated API method that now accepts TaggedUser objects
      final success = await repository.editPost(
        postId,
        content: content,
        taggedUsers: taggedUsers,
      );
      
      if (success) {
        // Update the post in the local posts list
        state = state.copyWith(
          posts: state.posts.map((post) {
            if (post.id == postId) {
              return post.copyWith(
                content: content,
                taggedUsers: taggedUsers ?? post.taggedUsers,
              );
            }
            return post;
          }).toList(),
        );
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error editing post: $e');
      return false;
    }
  }
      
  /// Report a post for policy violations
  Future<bool> reportPost(String postId, String policyViolation, {String? dontWantToSee}) async {
    // Existing implementation...
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

  /// Get the post likes
  Future<Map<String, dynamic>> getPostLikes(String postId, {int page = 1}) async {
    // Existing implementation...
    try {
      final likesData = await repository.getPostLikes(postId, page: page);
      return likesData;
    } catch (e) {
      debugPrint('Error getting post likes: $e');
      rethrow;
    }
  }

  // Add this method to your HomeViewModel class
  Future<bool> createRepost(String postId, {String? description}) async {
    try {
      // Call the repository method
      final success = await repository.createRepost(postId, description: description);
      
      if (success) {
        // After successful repost, refresh the feed to see the new repost
        await refreshFeed();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error creating repost: $e');
      rethrow;
    }
  }
}