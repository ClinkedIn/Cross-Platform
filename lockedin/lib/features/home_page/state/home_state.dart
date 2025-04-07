import '../model/post_model.dart';

/// State class for the Home page
class HomeState {
  /// List of posts to display
  final List<PostModel> posts;
  
  /// Loading indicator
  final bool isLoading;
  
  /// Error message, if any
  final String? error;

  /// Constructor
  HomeState({
    required this.posts, 
    required this.isLoading,
    this.error,
  });
  
  /// Create a copy of the current state with specified fields updated
  HomeState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
  
  /// Initial state factory
  factory HomeState.initial() => HomeState(
    posts: [], 
    isLoading: true,
  );
}