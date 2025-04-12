import 'dart:io';

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

  /// Constructor
  const PostState({
    this.content = '',
    this.attachments,
    this.isSubmitting = false,
    this.error,
    this.visibility = 'Anyone',
  });

  /// Creates a copy of this state with the given fields replaced
  PostState copyWith({
    String? content,
    List<File>? attachments,
    bool? isSubmitting,
    String? error,
    String? visibility,
  }) {
    return PostState(
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      visibility: visibility ?? this.visibility,
    );
  }

  /// Helper method to check if the post has content and can be submitted
  bool get canSubmit => (content.trim().isNotEmpty || attachments != null) && !isSubmitting;

  /// Initial empty state
  factory PostState.initial() => const PostState();
}