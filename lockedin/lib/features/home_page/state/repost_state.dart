import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/post_model.dart';

class RepostState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> pagination;
  final String postId;

  RepostState({
    required this.posts,
    required this.isLoading,
    this.error,
    required this.pagination,
    required this.postId,
  });

  factory RepostState.initial(String postId) => RepostState(
        posts: [],
        isLoading: false,
        error: null,
        pagination: {
          'total': 0,
          'page': 1,
          'limit': 10,
          'pages': 0,
          'hasNextPage': false,
          'hasPrevPage': false
        },
        postId: postId,
      );

  RepostState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
    String? postId,
  }) {
    return RepostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pagination: pagination ?? this.pagination,
      postId: postId ?? this.postId,
    );
  }
}

class RepostStateNotifier extends StateNotifier<RepostState> {
  RepostStateNotifier(String postId) : super(RepostState.initial(postId));

  void setLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }

  void updatePosts(List<PostModel> posts, Map<String, dynamic> pagination) {
    state = state.copyWith(
      posts: posts,
      isLoading: false,
      error: null,
      pagination: pagination,
    );
  }

  void addPosts(List<PostModel> newPosts, Map<String, dynamic> pagination) {
    state = state.copyWith(
      posts: [...state.posts, ...newPosts],
      isLoading: false,
      error: null,
      pagination: pagination,
    );
  }

  void setError(String errorMessage) {
    state = state.copyWith(isLoading: false, error: errorMessage);
  }

  void updatePost(String postId, PostModel updatedPost) {
    final index = state.posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final updatedPosts = List<PostModel>.from(state.posts);
      updatedPosts[index] = updatedPost;
      state = state.copyWith(posts: updatedPosts);
    }
  }

  void removePost(String postId) {
    final updatedPosts = state.posts.where((post) => post.id != postId).toList();
    state = state.copyWith(posts: updatedPosts);
  }
}

// Create a provider family for repost state, keyed by postId
final repostStateProvider = StateNotifierProviderFamily<RepostStateNotifier, RepostState, String>(
  (ref, postId) => RepostStateNotifier(postId),
);