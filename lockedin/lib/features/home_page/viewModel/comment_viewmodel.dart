import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../model/comment_model.dart';
import '../state/comment_state.dart';
import '../repository/posts/comment_api.dart';

// Create a provider for the CommentsApi first
final commentsApiProvider = Provider<CommentsApi>((ref) {
  return CommentsApi();
});

/// Provider for CommentsViewModel that takes a postId
final commentsViewModelProvider = StateNotifierProvider.family<CommentsViewModel, CommentsState, String>(
  (ref, postId) => CommentsViewModel(ref.read(commentsApiProvider), postId),
);

/// ViewModel for the comments view
class CommentsViewModel extends StateNotifier<CommentsState> {
  final CommentsApi api;
  final String postId;

  /// Constructor
  CommentsViewModel(this.api, this.postId) 
      : super(CommentsState.initial()) {
    fetchPostAndComments();
  }

  /// Fetch post details and comments
  Future<void> fetchPostAndComments() async {
    try {
      // Set initial loading state
      state = state.copyWith(isLoading: true, error: null);
      
      // First fetch the post details
      final post = await api.fetchPostDetail(postId);
      
      // Then fetch comments for this post
      final comments = await api.fetchComments(postId);
      
      // Sort comments based on current sort order
      final sortedComments = _sortComments(comments);
      
      // Update state with fetched post and comments
      state = state.copyWith(
        post: post,
        comments: sortedComments,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error fetching post and comments: $e');
      
      // Handle errors
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh just the comments
  Future<void> fetchComments() async {
    if (state.post == null) {
      // If we don't have a post yet, fetch everything
      await fetchPostAndComments();
      return;
    }
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final comments = await api.fetchComments(postId);
      final sortedComments = _sortComments(comments);
      
      state = state.copyWith(
        comments: sortedComments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
    /// Add a new comment
    Future<void> addComment(String content) async {
      if (content.trim().isEmpty || state.post == null) return;
      
      // Generate a temporary ID for optimistic updates
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('💬 Adding comment with tempId: $tempId');
      
      try {
        // Create a temporary comment with the best available user data
        // This will be replaced with real data from the API
        final tempComment = CommentModel(
          id: tempId,
          userId: 'current_user_id',
          username: 'You', // Simple placeholder
          profileImageUrl: '', 
          content: content,
          time: 'Just now',
          isLiked: false,
          likes: 0,
        );
        
        debugPrint('📝 Optimistically showing comment: "$content"');
        
        // Update the UI optimistically
        final updatedComments = [...state.comments, tempComment];
        final updatedPost = state.post!.copyWith(
          comments: state.post!.comments + 1,
        );
        
        state = state.copyWith(
          comments: updatedComments,
          post: updatedPost,
        );
        
        // Make the API call - this will fetch current user data internally
        debugPrint('🔄 Sending comment to API...');
        final newComment = await api.addComment(postId, content);
        debugPrint('✅ API returned comment from: ${newComment.username}');
        
        // Update UI with the real comment (with correct user data from API)
        final finalComments = state.comments.map((c) => 
          c.id == tempId ? newComment : c
        ).toList();
        
        state = state.copyWith(
          comments: _sortComments(finalComments),
        );
        
        debugPrint('✅ Comment added successfully and UI updated');
      } catch (e) {
        debugPrint('❌ Error adding comment: $e');
        
        // Remove the optimistic comment on failure
        final filteredComments = state.comments.where((c) => 
          !c.id.startsWith('temp_')
        ).toList();
        
        state = state.copyWith(
          comments: filteredComments,
          post: state.post?.copyWith(
            comments: state.post!.comments - 1,
          ),
          error: 'Failed to add comment: ${e.toString()}',
        );
      }
    }
  
  /// Change comment sort order
  void setSortOrder(CommentSortOrder sortOrder) {
    if (sortOrder == state.sortOrder) return;
    
    final sortedComments = _sortComments(state.comments, sortOrder);
    
    state = state.copyWith(
      sortOrder: sortOrder,
      comments: sortedComments,
    );
  }
  
  /// Toggle like on a comment
  Future<void> toggleCommentLike(String commentId) async {
    // Skip if toggleLikeComment is not implemented in the API yet
    final commentIndex = state.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;
    
    final comment = state.comments[commentIndex];
    final currentlyLiked = comment.isLiked;
    
    try {
      // Optimistically update UI
      final updatedComments = List<CommentModel>.from(state.comments);
      final updatedComment = comment.copyWith(
        isLiked: !currentlyLiked,
        likes: currentlyLiked ? comment.likes - 1 : comment.likes + 1,
      );
      
      updatedComments[commentIndex] = updatedComment;
      
      state = state.copyWith(comments: updatedComments);
      
      // Uncomment when API method is implemented:
      // final success = await api.toggleLikeComment(commentId);
      // 
      // if (!success) {
      //   // Revert on failure
      //   updatedComments[commentIndex] = comment;
      //   state = state.copyWith(comments: updatedComments);
      //   throw Exception('Failed to toggle like');
      // }
    } catch (e) {
      debugPrint('Error toggling comment like: $e');
      
      // In case of error, revert to the original comment
      final revertedComments = List<CommentModel>.from(state.comments);
      revertedComments[commentIndex] = comment;
      state = state.copyWith(comments: revertedComments);
    }
  }
  
  /// Reply to a comment (implementation for when API supports it)
  Future<void> replyToComment(String parentCommentId, String content) async {
    if (content.trim().isEmpty || state.post == null) return;
    
    try {
      // For now, just add as a regular comment since the API method is commented out
      await addComment(content);
      
      // Uncomment when API method is implemented:
      // final newComment = await api.replyToComment(postId, parentCommentId, content);
      // final updatedComments = [...state.comments, newComment];
      // final sortedComments = _sortComments(updatedComments);
      // 
      // final updatedPost = state.post!.copyWith(
      //   comments: state.post!.comments + 1,
      // );
      // 
      // state = state.copyWith(
      //   comments: sortedComments,
      //   post: updatedPost,
      // );
    } catch (e) {
      debugPrint('Error replying to comment: $e');
    }
  }
  
  /// Helper method to sort comments based on sort order
  List<CommentModel> _sortComments(List<CommentModel> comments, [CommentSortOrder? order]) {
    final sortOrder = order ?? state.sortOrder;
    final sorted = List<CommentModel>.from(comments);
    
    switch (sortOrder) {
      case CommentSortOrder.mostRelevant:
        // For "most relevant", sort by likes count
        sorted.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case CommentSortOrder.newest:
        // This is simplified - in a real app you'd parse the time strings
        // For now, we'll just reverse the list assuming newer comments are at the end
        return sorted.reversed.toList();
    }
    
    return sorted;
  }
}