import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/profile/widgets/post_card.dart';
import '../viewModel/comment_viewmodel.dart';
import '../state/comment_state.dart';
import '../model/comment_model.dart';

class PostDetailView extends ConsumerStatefulWidget {
  final String postId;
  
  const PostDetailView({
    required this.postId,
    Key? key,
  }) : super(key: key);
  
  @override
  ConsumerState<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends ConsumerState<PostDetailView> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyingToUsername;
  bool _isSubmittingComment = false;
  String? _currentUserProfilePicture;  // Add this line to store profile picture
  
  @override
  void initState() {
    super.initState();
    _loadUserProfilePicture(); // Load profile picture when widget initializes
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }
  // Add this method to load the profile picture
  Future<void> _loadUserProfilePicture() async {
    try {
      final commentsApi = ref.read(commentsApiProvider);
      final userData = await commentsApi.getCurrentUserData();
      if (mounted) {
        setState(() {
          _currentUserProfilePicture = userData['profilePicture'];
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsViewModelProvider(widget.postId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: commentsState.isLoading && !commentsState.hasPost
          ? _buildLoadingView()
          : commentsState.error != null && !commentsState.hasPost
              ? _buildErrorView(context, commentsState.error!, ref)
              : _buildContentView(context, commentsState, ref),
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
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                ref.read(commentsViewModelProvider(widget.postId).notifier)
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
  
  Widget _buildContentView(BuildContext context, CommentsState state, WidgetRef ref) {
    if (!state.hasPost) {
      return Center(child: Text('Post not found'));
    }
    
    return Column(
      children: [
        // Main content (post and comments)
        Expanded(
          child: RefreshIndicator(
          onRefresh: () async {
            // Save focus and cursor position state before refreshing
            final hadFocus = _commentFocusNode.hasFocus;
            final text = _commentController.text;
            final selection = _commentController.selection;
            
            await ref.read(commentsViewModelProvider(widget.postId).notifier).fetchPostAndComments();
            
            // Restore focus and text after refresh
            if (hadFocus) {
              Future.delayed(Duration(milliseconds: 100), () {
                _commentFocusNode.requestFocus();
                _commentController.text = text;
                _commentController.selection = selection;
              });
            }
          },
            child: CustomScrollView(
              slivers: [
                // Post card
                SliverToBoxAdapter(
                  child: PostCard(
                    post: state.post!,
                    onLike: () {
                      // This would need to handle like functionality
                      // You might need to create a separate provider or method
                    },
                    onComment: () {
                      // Focus the comment input field
                      _commentFocusNode.requestFocus();
                    },
                    onShare: () {
                      // Handle share functionality
                    },
                    onFollow: () {
                      // Handle follow functionality
                    },
                    onRepost: () {
                      // Handle repost functionality
                    },
                  ),
                ),
                
                // Divider
                SliverToBoxAdapter(
                  child: Divider(thickness: 0.5.h, height: 1.h),
                ),
                
                // Comments header with sort options
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${state.comments.length})',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildSortDropdown(state, ref),
                      ],
                    ),
                  ),
                ),
                
                // Comments list or loading/empty state
                state.isLoading && state.comments.isEmpty 
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(4.h),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      )
                    : state.comments.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyCommentsView())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildCommentItem(
                                context, 
                                state.comments[index],
                                ref,
                              ),
                              childCount: state.comments.length,
                            ),
                          ),
              ],
            ),
          ),
        ),
        
        // Comment input field
        _buildCommentInputField(context, ref),
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
        DropdownMenuItem(
          value: CommentSortOrder.newest,
          child: Text('Newest'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(commentsViewModelProvider(widget.postId).notifier)
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
          Icon(
            Icons.chat_bubble_outline,
            size: 8.h,
            color: Colors.grey[400],
          ),
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
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentItem(BuildContext context, CommentModel comment, WidgetRef ref) {
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
            child: comment.profileImageUrl.isEmpty ? Icon(Icons.person, size: 3.h) : null,
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
                    color: Theme.of(context).brightness == Brightness.dark 
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
                      
                      if (comment.designation != null && comment.designation!.isNotEmpty)
                        Text(
                          comment.designation!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      
                      SizedBox(height: 0.5.h),
                      
                      // Comment content
                      Text(
                        comment.content,
                        style: TextStyle(
                          fontSize: 15.sp,
                        ),
                      ),
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
                          ref.read(commentsViewModelProvider(widget.postId).notifier)
                            .toggleCommentLike(comment.id);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          minimumSize: Size(0, 3.h),
                          foregroundColor: comment.isLiked 
                              ? AppColors.primary 
                              : Colors.grey[600],
                        ),
                        child: Text('Like'),
                      ),
                      
                      // Reply button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _replyingToUsername = comment.username;
                            _commentController.text = '@${comment.username} ';
                            _commentFocusNode.requestFocus();
                          });
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
  
  Widget _buildCommentInputField(BuildContext context, WidgetRef ref) {
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
          if (_replyingToUsername != null)
            Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  Text(
                    'Replying to $_replyingToUsername',
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
                    onPressed: () {
                      setState(() {
                        _replyingToUsername = null;
                        _commentController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // User avatar (replace with current user's avatar)
              CircleAvatar(
                radius: 2.h,
                backgroundImage: _currentUserProfilePicture != null && _currentUserProfilePicture!.isNotEmpty
                    ? NetworkImage(_currentUserProfilePicture!)
                    : null,
                backgroundColor: Colors.grey[300],
                // Show placeholder if no image is available
                child: (_currentUserProfilePicture == null || _currentUserProfilePicture!.isEmpty)
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              SizedBox(width: 2.w),
              
              // Comment input field
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                  ),
                  maxLines: null,
                ),
              ),
              
              // Send button
              SizedBox(width: 1.w),
              _isSubmittingComment
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
                      onPressed: () => _submitComment(ref),
                    ),
            ],
          ),
        ],
      ),
    );
  }
  
    void _submitComment(WidgetRef ref) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    debugPrint('📝 Submitting comment: $content');
    
    try {
      await ref.read(commentsViewModelProvider(widget.postId).notifier)
        .addComment(content);
      
      _commentController.clear();
      setState(() {
        _replyingToUsername = null;
        _isSubmittingComment = false;
      });
      
      // Show success message
      debugPrint('✅ Comment successfully sent to backend!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment posted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmittingComment = false;
      });
      debugPrint('❌ Failed to send comment: $e');
      // Show error message with the specific error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment: ${e.toString().split(': ').last}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showCommentOptions(BuildContext context, CommentModel comment, WidgetRef ref) {
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