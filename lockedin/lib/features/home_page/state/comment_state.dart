import '../model/comment_model.dart';
import '../model/post_model.dart';

/// State class for the Comments view
class CommentsState {
  /// The post being commented on
  final PostModel? post;
  
  /// List of comments for this post
  final List<CommentModel> comments;
  
  /// Loading indicator
  final bool isLoading;
  
  /// Error message, if any
  final String? error;
  
  /// Sort order for comments
  final CommentSortOrder sortOrder;

  /// Constructor
  CommentsState({
    this.post,
    required this.comments,
    required this.isLoading,
    this.error,
    this.sortOrder = CommentSortOrder.mostRelevant,
  });
  
  /// Create a copy of the current state with specified fields updated
  CommentsState copyWith({
    PostModel? post,
    List<CommentModel>? comments,
    bool? isLoading,
    String? error,
    CommentSortOrder? sortOrder,
  }) {
    return CommentsState(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
  
  /// Initial state factory - without requiring a post
  factory CommentsState.initial() => CommentsState(
    comments: [],
    isLoading: true,
  );
  
  /// Factory constructor for when we already have a post
  factory CommentsState.withPost(PostModel post) => CommentsState(
    post: post,
    comments: [],
    isLoading: true,
  );
  
  /// Check if the state has a valid post
  bool get hasPost => post != null;
}

/// Enum for comment sort order
enum CommentSortOrder {
  mostRelevant,
  newest,
}