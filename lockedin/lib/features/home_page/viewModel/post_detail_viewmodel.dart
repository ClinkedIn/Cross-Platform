import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/taggeduser_model.dart';
import '../viewModel/comment_viewmodel.dart';
import '../viewModel/home_viewmodel.dart';

// Define a state class for the PostDetailViewModel
class PostDetailState {
  final TextEditingController commentController;
  final FocusNode commentFocusNode;
  final String? replyingToUsername;
  final bool isSubmittingComment;
  final String? currentUserProfilePicture;
  final bool showMentionSuggestions;
  final String mentionQuery;
  final int mentionStartIndex;
  final List<TaggedUser> taggedUsers;

  PostDetailState({
    required this.commentController,
    required this.commentFocusNode,
    this.replyingToUsername,
    this.isSubmittingComment = false,
    this.currentUserProfilePicture,
    this.showMentionSuggestions = false,
    this.mentionQuery = '',
    this.mentionStartIndex = -1,
    this.taggedUsers = const [],
  });

  // Create a copy of the state with updated values
  PostDetailState copyWith({
    TextEditingController? commentController,
    FocusNode? commentFocusNode,
    String? Function()? replyingToUsername,
    bool? isSubmittingComment,
    String? Function()? currentUserProfilePicture,
    bool? showMentionSuggestions,
    String? mentionQuery,
    int? mentionStartIndex,
    List<TaggedUser>? taggedUsers,
  }) {
    return PostDetailState(
      commentController: commentController ?? this.commentController,
      commentFocusNode: commentFocusNode ?? this.commentFocusNode,
      replyingToUsername: replyingToUsername != null
          ? replyingToUsername()
          : this.replyingToUsername,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      currentUserProfilePicture: currentUserProfilePicture != null
          ? currentUserProfilePicture()
          : this.currentUserProfilePicture,
      showMentionSuggestions: showMentionSuggestions ?? this.showMentionSuggestions,
      mentionQuery: mentionQuery ?? this.mentionQuery,
      mentionStartIndex: mentionStartIndex ?? this.mentionStartIndex,
      taggedUsers: taggedUsers ?? this.taggedUsers,
    );
  }
}

// Create a provider for the PostDetailViewModel
final postDetailViewModelProvider = StateNotifierProvider.family<PostDetailViewModel, PostDetailState, String>(
  (ref, postId) => PostDetailViewModel(ref, postId),
);

class PostDetailViewModel extends StateNotifier<PostDetailState> {
  final Ref _ref;
  final String postId;
  Timer? _debounce;

  PostDetailViewModel(this._ref, this.postId)
      : super(PostDetailState(
          commentController: TextEditingController(),
          commentFocusNode: FocusNode(),
        )) {
    // Initialize the ViewModel
    _init();
  }

  void _init() {
    state.commentController.addListener(_onCommentChanged);
    _loadUserProfilePicture();
  }

  @override
  void dispose() {
    state.commentController.removeListener(_onCommentChanged);
    state.commentController.dispose();
    state.commentFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onCommentChanged() {
    final text = state.commentController.text;
    final selection = state.commentController.selection;
    
    if (selection.baseOffset != selection.extentOffset) {
      // If there's a selection, don't try to find mentions
      state = state.copyWith(showMentionSuggestions: false);
      return;
    }
    
    final currentPosition = selection.baseOffset;
    
    // Find the last @ before the cursor
    int lastAtIndex = -1;
    for (int i = currentPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        lastAtIndex = i;
        break;
      } else if (text[i] == ' ' || text[i] == '\n') {
        // Stop at spaces or newlines
        break;
      }
    }
    
    if (lastAtIndex >= 0) {
      // Extract query text between @ and cursor
      final query = text.substring(lastAtIndex + 1, currentPosition);
      
      if (query.isNotEmpty) {
        state = state.copyWith(
          mentionStartIndex: lastAtIndex,
          mentionQuery: query,
          showMentionSuggestions: true,
        );
        
        // Debounce search to avoid too many API calls
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          _searchUsers(query);
        });
        return;
      }
    }
    
    state = state.copyWith(showMentionSuggestions: false);
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) return;

    try {
      await _ref
          .read(commentsViewModelProvider(postId).notifier)
          .searchUsers(query);
    } catch (e) {
      debugPrint('Error searching users: $e');
    }
  }

  void onMentionSelected(TaggedUser user) {
    final text = state.commentController.text;
    final mentionText = "${user.firstName} ${user.lastName}";
    
    // Replace the @query with the selected username
    final newText = text.replaceRange(
      state.mentionStartIndex, 
      state.commentController.selection.baseOffset, 
      "@$mentionText "
    );
    
    // Add the user to tagged users list if not already there
    List<TaggedUser> updatedTaggedUsers = List.from(state.taggedUsers);
    if (!updatedTaggedUsers.any((u) => u.userId == user.userId)) {
      updatedTaggedUsers.add(user);
    }
    
    // Update the text and cursor position
    state.commentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: state.mentionStartIndex + mentionText.length + 2, // +2 for @ and space
      ),
    );
    
    state = state.copyWith(
      taggedUsers: updatedTaggedUsers,
      showMentionSuggestions: false,
    );
  }

  Future<void> _loadUserProfilePicture() async {
    try {
      final commentsApi = _ref.read(commentsApiProvider);
      final userData = await commentsApi.getCurrentUserData();
      state = state.copyWith(
        currentUserProfilePicture: () => userData['profilePicture'],
      );
    } catch (e) {
      debugPrint('❌ Error loading user profile picture: $e');
    }
  }

  void setReplyingToUsername(String? username) {
    state = state.copyWith(
      replyingToUsername: () => username,
    );
    
    if (username != null) {
      state.commentController.text = '@$username ';
      state.commentFocusNode.requestFocus();
    } else {
      state.commentController.clear();
    }
  }

  void cancelReply() {
    state = state.copyWith(
      replyingToUsername: () => null,
    );
    state.commentController.clear();
  }

  void removeTaggedUser(String userId) {
    final updatedTaggedUsers = List<TaggedUser>.from(state.taggedUsers)
      ..removeWhere((u) => u.userId == userId);
    
    state = state.copyWith(taggedUsers: updatedTaggedUsers);
  }

  Future<void> submitComment() async {
    final content = state.commentController.text.trim();
    if (content.isEmpty) return;

    state = state.copyWith(isSubmittingComment: true);

    debugPrint('📝 Submitting comment: $content');
    if (state.taggedUsers.isNotEmpty) {
      debugPrint('👥 With ${state.taggedUsers.length} tagged users');
    }

    try {
      await _ref
          .read(commentsViewModelProvider(postId).notifier)
          .addComment(
            content, 
            taggedUsers: state.taggedUsers.isNotEmpty ? state.taggedUsers : null
          );

      state.commentController.clear();
      state = state.copyWith(
        replyingToUsername: () => null,
        isSubmittingComment: false,
        taggedUsers: [],
      );

      // Return success for UI feedback
      return Future.value();
    } catch (e) {
      state = state.copyWith(isSubmittingComment: false);
      debugPrint('❌ Failed to send comment: $e');
      throw e; // Propagate error to the UI
    }
  }

  // Methods for handling post actions
  Future<void> likePost() async {
    try {
      await _ref
          .read(homeViewModelProvider.notifier)
          .toggleLike(
            _ref.read(commentsViewModelProvider(postId)).post!.id
          );
      
      // Refresh post data after like
      _ref
          .read(commentsViewModelProvider(postId).notifier)
          .fetchPostAndComments();
    } catch (e) {
      // Check if this is the "already liked" error
      if (e.toString().contains("already liked this post")) {
        debugPrint('Post state mismatch detected - refreshing data');
        
        // Silently refresh the post to sync with server state
        _ref
            .read(commentsViewModelProvider(postId).notifier)
            .fetchPostAndComments();
      } else {
        // For other errors, propagate to UI
        rethrow;
      }
    }
  }

  Future<void> repostPost() async {
    try {
      await _ref
          .read(homeViewModelProvider.notifier)
          .toggleRepost(
            _ref.read(commentsViewModelProvider(postId)).post!.id
          );
      
      // Refresh post data
      _ref
          .read(commentsViewModelProvider(postId).notifier)
          .fetchPostAndComments();
      
      return Future.value();
    } catch (e) {
      debugPrint("Error reposting: $e");
      rethrow;
    }
  }

  Future<void> savePostForLater() async {
    try {
      await _ref
          .read(homeViewModelProvider.notifier)
          .toggleSaveForLater(
            _ref.read(commentsViewModelProvider(postId)).post!.id
          );
      return Future.value();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportPost(String reason) async {
    try {
      await _ref.read(homeViewModelProvider.notifier)
          .reportPost(
            _ref.read(commentsViewModelProvider(postId)).post!.id, 
            reason
          );
      return Future.value();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost() async {
    try {
      await _ref.read(homeViewModelProvider.notifier)
          .deletePost(
            _ref.read(commentsViewModelProvider(postId)).post!.id
          );
      return Future.value();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleCommentLike(String commentId) async {
    await _ref
        .read(commentsViewModelProvider(postId).notifier)
        .toggleCommentLike(commentId);
  }
}