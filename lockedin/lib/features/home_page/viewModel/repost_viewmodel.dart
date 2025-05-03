import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/home_page/repository/posts/post_api.dart';
import 'package:lockedin/features/home_page/repository/repost_api.dart';
import 'package:lockedin/features/home_page/state/repost_state.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';

class RepostViewModel {
  final RepostApi _repostApi;
  final PostApi _postApi;
  final RepostStateNotifier _stateNotifier;
  final String postId;

  RepostViewModel(this._repostApi, this._postApi, this._stateNotifier, this.postId) {
    // Initial load happens in the view
  }


  // Update the loadReposts method
Future<void> loadReposts({int page = 1}) async {
  try {
    _stateNotifier.setLoading();
    final posts = await _repostApi.fetchRepostsForPost(postId, page: page);
    
    // Create a simple pagination map since the API now returns just posts
    final pagination = {
      'total': posts.length,
      'page': page,
      'limit': 10,
      'pages': (posts.length / 10).ceil(),
      'hasNextPage': false, // Simplified since we're not using pagination now
      'hasPrevPage': page > 1
    };
    
    _stateNotifier.updatePosts(posts, pagination);
  } catch (e) {
    debugPrint('Error loading reposts: $e');
    _stateNotifier.setError('Failed to load reposts: $e');
  }
}

// Update refreshReposts method
Future<void> refreshReposts() async {
  try {
    _stateNotifier.setLoading();
    final posts = await _repostApi.fetchRepostsForPost(postId, page: 1);
    
    final pagination = {
      'total': posts.length,
      'page': 1,
      'limit': 10,
      'pages': (posts.length / 10).ceil(),
      'hasNextPage': false,
      'hasPrevPage': false
    };
    
    _stateNotifier.updatePosts(posts, pagination);
  } catch (e) {
    debugPrint('Error refreshing reposts: $e');
    _stateNotifier.setError('Failed to refresh reposts: $e');
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
    }
  }
}

// Provider for the repost view model
final repostViewModelProvider = Provider.family<RepostViewModel, String>((ref, postId) {
  final stateNotifier = ref.watch(repostStateProvider(postId).notifier);
  return RepostViewModel(
    RepostApi(),
    PostApi(),
    stateNotifier,
    postId,
  );
});