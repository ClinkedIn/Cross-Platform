import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/post/widgets/post_card.dart';
import '../viewModel/comment_viewmodel.dart';
import '../state/comment_state.dart';
import '../model/comment_model.dart';
import '../viewModel/post_detail_viewmodel.dart';
import 'package:go_router/go_router.dart';

class PostDetailView extends ConsumerWidget {
  final String postId;

  const PostDetailView({required this.postId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsState = ref.watch(commentsViewModelProvider(postId));
    final postDetailState = ref.watch(postDetailViewModelProvider(postId));
    final postDetailViewModel = ref.read(postDetailViewModelProvider(postId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          commentsState.isLoading && !commentsState.hasPost
              ? _buildLoadingView()
              : commentsState.error != null && !commentsState.hasPost
              ? _buildErrorView(context, commentsState.error!, ref)
              : _buildContentView(context, commentsState, postDetailState, postDetailViewModel, ref),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 2.h),
          Text('Loading post...'),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 10.h, color: Colors.red),
            SizedBox(height: 2.h),
            Text(
              'Failed to load post',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(commentsViewModelProvider(postId).notifier)
                    .fetchPostAndComments();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 1.h),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(
    BuildContext context,
    CommentsState commentsState,
    PostDetailState postDetailState,
    PostDetailViewModel viewModel,
    WidgetRef ref,
  ) {
    if (!commentsState.hasPost) {
      return Center(child: Text('Post not found'));
    }

    return Column(
      children: [
        // Main content (post and comments)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Save focus and cursor position state before refreshing
              final hadFocus = postDetailState.commentFocusNode.hasFocus;
              final text = postDetailState.commentController.text;
              final selection = postDetailState.commentController.selection;

              await ref
                  .read(commentsViewModelProvider(postId).notifier)
                  .fetchPostAndComments();

              // Restore focus and text after refresh
              if (hadFocus) {
                Future.delayed(Duration(milliseconds: 100), () {
                  postDetailState.commentFocusNode.requestFocus();
                  postDetailState.commentController.text = text;
                  postDetailState.commentController.selection = selection;
                });
              }
            },
            child: CustomScrollView(
              slivers: [
                // Post card
                SliverToBoxAdapter(
                  child: PostCard(
                    post: commentsState.post!,
                    onLike: () async {
                      try {
                        await viewModel.likePost();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update like status'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    onComment: () {
                      // Focus the comment input field
                      postDetailState.commentFocusNode.requestFocus();
                    },
                    onShare: () async {
                      print("Shared post: ${commentsState.post!.id}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening share options...')),
                      );
                    },
                    onRepost: () async {
                      try {
                        await viewModel.repostPost();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                commentsState.post!.isRepost
                                    ? 'Repost removed'
                                    : 'Post reposted successfully',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    onFollow: () {
                      print("Following ${commentsState.post!.username}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Following ${commentsState.post!.username}...')),
                      );
                    },
                    onSaveForLater: () async {
                      try {
                        await viewModel.savePostForLater();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Post saved for later',
                                style: TextStyle(color: Colors.black87),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.white,
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height - 200,
                                left: 10,
                                right: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    onReport: () async {
                      final List<String> reportReasons = [
                        "Harassment",
                        "Fraud or scam",
                        "Spam",
                        "Misinformation",
                        "Hateful speech",
                        "Threats or violence",
                        "Self-harm",
                        "Graphic content",
                        "Dangerous or extremist organizations",
                        "Sexual content",
                        "Fake account",
                        "Child exploitation",
                        "Illegal goods and services",
                        "Infringement",
                        "This person is impersonating someone",
                        "This account has been hacked",
                        "This account is not a real person",
                      ];
                      
                      final selectedReason = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Report Post'),
                          content: Container(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Why are you reporting this post?'),
                                SizedBox(height: 2.h),
                                Container(
                                  height: 40.h,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: reportReasons.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(reportReasons[index]),
                                        onTap: () => Navigator.pop(context, reportReasons[index]),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                      
                      if (selectedReason != null) {
                        try {
                          await viewModel.reportPost(selectedReason);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Post reported successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to report post: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    onNotInterested: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You won\'t see similar posts'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onEdit: commentsState.post!.isMine ? () {
                      context.push('/edit-post', extra: commentsState.post);
                    } : null,
                    onDelete: (commentsState.post!.isMine && commentsState.post!.userId.isNotEmpty) ? () async {
                      final delete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Post'),
                          content: Text('Are you sure you want to delete this post?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      
                      if (delete == true) {
                        try {
                          await viewModel.deletePost();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Post deleted successfully')),
                            );
                            // Go back to previous screen after deletion
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete post: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    } : null,
                  ),
                ),

                // Divider
                SliverToBoxAdapter(
                  child: Divider(thickness: 0.5.h, height: 1.h),
                ),

                // Comments header with sort options
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.h,
                      vertical: 1.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${commentsState.comments.length})',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildSortDropdown(commentsState, ref),
                      ],
                    ),
                  ),
                ),

                // Comments list or loading/empty state
                commentsState.isLoading && commentsState.comments.isEmpty
                    ? SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(4.h),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                    : commentsState.comments.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyCommentsView())
                    : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCommentItem(
                          context,
                          commentsState.comments[index],
                          ref,
                          viewModel,
                        ),
                        childCount: commentsState.comments.length,
                      ),
                    ),
              ],
            ),
          ),
        ),

        // Comment input field
        _buildCommentInputField(context, commentsState, postDetailState, viewModel, ref),
      ],
    );
  }

  Widget _buildSortDropdown(CommentsState state, WidgetRef ref) {
    return DropdownButton<CommentSortOrder>(
      value: state.sortOrder,
      underline: SizedBox(),
      icon: Icon(Icons.keyboard_arrow_down),
      items: [
        DropdownMenuItem(
          value: CommentSortOrder.mostRelevant,
          child: Text('Most relevant'),
        ),
        DropdownMenuItem(value: CommentSortOrder.newest, child: Text('Newest')),
      ],
      onChanged: (value) {
        if (value != null) {
          ref
              .read(commentsViewModelProvider(postId).notifier)
              .setSortOrder(value);
        }
      },
    );
  }

  Widget _buildEmptyCommentsView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 8.h, color: Colors.grey[400]),
          SizedBox(height: 1.h),
          Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Be the first to share your thoughts',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    CommentModel comment,
    WidgetRef ref,
    PostDetailViewModel viewModel,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          CircleAvatar(
            backgroundImage: NetworkImage(comment.profileImageUrl),
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error loading profile image: $exception');
            },
            radius: 2.5.h,
            child:
                comment.profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 3.h)
                    : null,
          ),

          SizedBox(width: 2.w),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment bubble with user info and content
                Container(
                  padding: EdgeInsets.all(1.5.h),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(1.h),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username and designation
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              comment.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      if (comment.designation != null &&
                          comment.designation!.isNotEmpty)
                        Text(
                          comment.designation!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),

                      SizedBox(height: 0.5.h),

                      // Comment content
                      Text(comment.content, style: TextStyle(fontSize: 15.sp)),
                    ],
                  ),
                ),

                // Action buttons and time
                Padding(
                  padding: EdgeInsets.only(left: 1.h, top: 0.5.h),
                  child: Row(
                    children: [
                      // Time
                      Text(
                        "${comment.time} ${comment.isEdited ? '· Edited' : ''}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),

                      SizedBox(width: 2.w),

                      // Like button
                      TextButton(
                        onPressed: () {
                          viewModel.toggleCommentLike(comment.id);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          minimumSize: Size(0, 3.h),
                          foregroundColor:
                              comment.isLiked
                                  ? AppColors.primary
                                  : Colors.grey[600],
                        ),
                        child: Text('Like'),
                      ),

                      // Reply button
                      TextButton(
                        onPressed: () {
                          viewModel.setReplyingToUsername(comment.username);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          minimumSize: Size(0, 3.h),
                          foregroundColor: Colors.grey[600],
                        ),
                        child: Text('Reply'),
                      ),

                      if (comment.likes > 0) ...[
                        Spacer(),
                        // Like count
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 1.5.h,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 0.5.w),
                            Text(
                              '${comment.likes}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onPressed: () => _showCommentOptions(context, comment, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField(
    BuildContext context, 
    CommentsState commentsState,
    PostDetailState postDetailState,
    PostDetailViewModel viewModel,
    WidgetRef ref
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply indicator
          if (postDetailState.replyingToUsername != null)
            Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  Text(
                    'Replying to ${postDetailState.replyingToUsername}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, size: 2.h),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => viewModel.cancelReply(),
                  ),
                ],
              ),
            ),
            
          // Tagged users chips
          if (postDetailState.taggedUsers.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 1.h),
              child: Wrap(
                spacing: 1.w,
                runSpacing: 0.5.h,
                children: postDetailState.taggedUsers.map((user) {
                  return Chip(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    avatar: CircleAvatar(
                      backgroundImage: user.profilePicture != null && 
                                      user.profilePicture!.isNotEmpty
                          ? NetworkImage(user.profilePicture!)
                          : null,
                      child: (user.profilePicture == null || 
                              user.profilePicture!.isEmpty)
                          ? Icon(Icons.person, size: 1.5.h)
                          : null,
                    ),
                    label: Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    deleteIcon: Icon(Icons.close, size: 1.5.h),
                    onDeleted: () => viewModel.removeTaggedUser(user.userId),
                  );
                }).toList(),
              ),
            ),
            
          // User mention suggestions
          if (postDetailState.showMentionSuggestions && commentsState.userSearchResults.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 30.h),
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: commentsState.userSearchResults.length,
                itemBuilder: (context, index) {
                  final user = commentsState.userSearchResults[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.h,
                      vertical: 0.5.h,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: user.profilePicture != null && 
                                    user.profilePicture!.isNotEmpty
                          ? NetworkImage(user.profilePicture!)
                          : null,
                      child: (user.profilePicture == null || 
                              user.profilePicture!.isEmpty)
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: user.headline != null && user.headline!.isNotEmpty
                        ? Text(
                            user.headline!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => viewModel.onMentionSelected(user),
                  );
                },
              ),
            ),
            
          // Main input row
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 2.h,
                backgroundImage:
                    postDetailState.currentUserProfilePicture != null &&
                            postDetailState.currentUserProfilePicture!.isNotEmpty
                        ? NetworkImage(postDetailState.currentUserProfilePicture!)
                        : null,
                backgroundColor: Colors.grey[300],
                child:
                    (postDetailState.currentUserProfilePicture == null ||
                            postDetailState.currentUserProfilePicture!.isEmpty)
                        ? Icon(Icons.person, color: Colors.grey[600])
                        : null,
              ),
              SizedBox(width: 2.w),

              // Comment input field
              Expanded(
                child: TextField(
                  controller: postDetailState.commentController,
                  focusNode: postDetailState.commentFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a comment... Type @ to mention someone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.h,
                      vertical: 1.h,
                    ),
                  ),
                  maxLines: null,
                ),
              ),

              // Submit button
              SizedBox(width: 1.w),
              postDetailState.isSubmittingComment
                  ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: SizedBox(
                      width: 3.h,
                      height: 3.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: Icon(Icons.send, color: AppColors.primary),
                    onPressed: () async {
                      try {
                        await viewModel.submitComment();
                        
                        // Show success message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Comment posted successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        // Show error message with the specific error
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add comment: ${e.toString().split(': ').last}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommentOptions(
    BuildContext context,
    CommentModel comment,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy comment'),
                onTap: () {
                  Navigator.pop(context);
                  // Copy to clipboard functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.report_outlined),
                title: Text('Report comment'),
                onTap: () {
                  Navigator.pop(context);
                  // Report comment functionality
                },
              ),
              // Add more options like delete if user owns the comment
              if (comment.userId == 'current_user_id')
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete comment',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Delete comment functionality
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}