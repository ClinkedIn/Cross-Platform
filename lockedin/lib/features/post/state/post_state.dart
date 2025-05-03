import 'dart:io';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';

/// State class for the post creation page
class PostState {
  /// Text content of the post
  final String content;

  /// Selected image file (if any)
  final List<File>? attachments;

  /// Whether a post is currently being submitted
  final bool isSubmitting;

  /// Any error that occurred during submission
  final String? error;
  
  /// Post visibility setting (Anyone/Connections)
  final String visibility;

  final String fileType; // Add this field

    final bool showMentionSuggestions;
    final String mentionQuery;
    final int mentionStartIndex;
    final List<TaggedUser> taggedUsers;
    final List<TaggedUser> userSearchResults;
    final bool isSearchingUsers;

  /// Constructor
  const PostState({
    this.content = '',
    this.attachments,
    this.isSubmitting = false,
    this.error,
    this.visibility = 'Anyone',
    this.fileType = 'image', // Default to image
    this.showMentionSuggestions = false,
    this.mentionQuery = '',
    this.mentionStartIndex = -1,
    this.taggedUsers = const [],
    this.userSearchResults = const [],
    this.isSearchingUsers = false,
  });

  /// Creates a copy of this state with the given fields replaced
  PostState copyWith({
    String? content,
    List<File>? attachments,
    bool? isSubmitting,
    String? error,
    String? visibility,
    String? fileType, // Add this parameter
    bool? showMentionSuggestions,
    String? mentionQuery,
    int? mentionStartIndex,
    List<TaggedUser>? taggedUsers,
    List<TaggedUser>? userSearchResults,
    bool? isSearchingUsers,
  }) {
    return PostState(
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      visibility: visibility ?? this.visibility,
      fileType: fileType ?? this.fileType,
      showMentionSuggestions: showMentionSuggestions ?? this.showMentionSuggestions,
      mentionQuery: mentionQuery ?? this.mentionQuery,
      mentionStartIndex: mentionStartIndex ?? this.mentionStartIndex,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      userSearchResults: userSearchResults ?? this.userSearchResults,
      isSearchingUsers: isSearchingUsers ?? this.isSearchingUsers,
    );
  }

  /// Helper method to check if the post has content and can be submitted
  bool get canSubmit => (content.trim().isNotEmpty || attachments != null) && !isSubmitting;

  /// Initial empty state
  factory PostState.initial() => const PostState();

  
}