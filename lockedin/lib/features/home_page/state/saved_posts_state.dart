import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';

// Define the state class for saved posts
class SavedPostsState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  SavedPostsState({
    required this.posts,
    required this.isLoading,
    this.error,
  });

  // Initial state factory constructor
  factory SavedPostsState.initial() {
    return SavedPostsState(
      posts: [],
      isLoading: true,
      error: null,
    );
  }

  // Copy with method for immutability
  SavedPostsState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
  }) {
    return SavedPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Create a StateNotifier for the saved posts state
class SavedPostsStateNotifier extends StateNotifier<SavedPostsState> {
  SavedPostsStateNotifier() : super(SavedPostsState.initial());

  // Update posts in the state
  void updatePosts(List<PostModel> posts) {
    state = state.copyWith(posts: posts, isLoading: false, error: null);
  }

  // Set loading state
  void setLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }

  // Set error state
  void setError(String message) {
    state = state.copyWith(isLoading: false, error: message);
  }

  // Update a specific post in the list
  void updatePost(String postId, PostModel updatedPost) {
    final postIndex = state.posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = updatedPost;
    state = state.copyWith(posts: updatedPosts);
  }

  // Remove a post from the list
  void removePost(String postId) {
    final updatedPosts = state.posts.where((post) => post.id != postId).toList();
    state = state.copyWith(posts: updatedPosts);
  }
}

// State provider
final savedPostsStateProvider = StateNotifierProvider<SavedPostsStateNotifier, SavedPostsState>((ref) {
  return SavedPostsStateNotifier();
});