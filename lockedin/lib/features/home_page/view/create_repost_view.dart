import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/viewModel/home_viewmodel.dart';
import 'package:lockedin/features/post/widgets/post_card.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart'; // Add this import

class CreateRepostView extends ConsumerStatefulWidget {
  final PostModel post;
  
  const CreateRepostView({required this.post, Key? key}) : super(key: key);
  
  @override
  ConsumerState<CreateRepostView> createState() => _CreateRepostViewState();
}

class _CreateRepostViewState extends ConsumerState<CreateRepostView> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider); // Use the same userProvider as in PostPage
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _isSubmitting
              ? Padding(
                  padding: EdgeInsets.all(2.w),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 0.5.w,
                  ),
                )
              : FilledButton(
                  onPressed: _submitRepost,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  child: Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add description section
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info for who is reposting - Fixed to match PostPage approach
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6.w,
                        backgroundImage: userState.whenOrNull(
                          data: (user) => user.profilePicture != null && user.profilePicture!.isNotEmpty
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        ),
                        backgroundColor: Colors.grey[300],
                        onBackgroundImageError: (_, __) {},
                        child: userState.when(
                          data: (user) => (user.profilePicture == null || user.profilePicture!.isEmpty)
                            ? Icon(Icons.person, color: Colors.white)
                            : null,
                          error: (_, __) => Icon(Icons.person, color: Colors.white),
                          loading: () => Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Display user's name with proper state handling
                      Expanded(
                        child: userState.when(
                          data: (user) => Text(
                            '${user.firstName} ${user.lastName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          loading: () => Text(
                            'Loading...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                          error: (_, __) => Text(
                            'User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Description text field
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Add a comment about this post (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1.h),
                        borderSide: BorderSide(color: AppColors.gray.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1.h),
                        borderSide: BorderSide(color: AppColors.gray.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1.h),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.all(3.w),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(height: 0.5.h, thickness: 0.5.h, color: AppColors.gray.withOpacity(0.2)),
            
            // Preview label
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Icon(Icons.preview_outlined, color: AppColors.gray),
                  SizedBox(width: 2.w),
                  Text(
                    'Post Preview',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Post preview
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: PostCard(
                post: widget.post,
                onLike: () {},
                onComment: () {},
                onShare: () {},
                onRepost: () {},
                onFollow: () {},
                // Disable all interactions in the preview
              ),
            ),
            
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
  
  Future<void> _submitRepost() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final description = _descriptionController.text.trim();
      final userstate =ref.read(userProvider);
      final userid =userstate.when(data: (user) => user.id, loading: () => '', error: (_, __) => '');
      final success = await ref.read(homeViewModelProvider.notifier)
        .toggleRepost(widget.post.id, userid,description: description.isNotEmpty ? description : null);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post shared successfully')),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share post')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}