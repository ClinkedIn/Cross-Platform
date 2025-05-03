import '../model/post_model.dart';

/// State class for the Home page
class HomeState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalPosts;
  final bool hasNextPage;
  final bool hasPrevPage;
  final bool isLoadingMore;
  final int limit;

  HomeState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalPosts = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.isLoadingMore = false,
    this.limit = 10,
  });

  /// Factory constructor to create initial state with default values
  factory HomeState.initial() {
    return HomeState(
      posts: [],
      isLoading: false,
      error: null,
      currentPage: 1,
      totalPages: 1,
      totalPosts: 0,
      hasNextPage: false,
      hasPrevPage: false,
      isLoadingMore: false,
      limit: 10,
    );
  }

  HomeState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalPosts,
    bool? hasNextPage,
    bool? hasPrevPage,
    bool? isLoadingMore,
    int? limit,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // Set to null if not provided
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalPosts: totalPosts ?? this.totalPosts,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPrevPage: hasPrevPage ?? this.hasPrevPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      limit: limit ?? this.limit,
    );
  }
}