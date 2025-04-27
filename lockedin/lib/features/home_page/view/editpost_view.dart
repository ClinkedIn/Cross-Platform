import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/viewModel/home_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class EditPostPage extends ConsumerStatefulWidget {
  final PostModel post;
  
  const EditPostPage({required this.post, Key? key}) : super(key: key);

  @override
  ConsumerState<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends ConsumerState<EditPostPage> {
  late TextEditingController _contentController;
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Post',
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
                  onPressed: _contentController.text.isNotEmpty
                      ? _updatePost
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _contentController.text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.gray.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  child: Text(
                    'Save',
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
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 6.w,
                    backgroundImage: NetworkImage(widget.post.profileImageUrl),
                    onBackgroundImageError: (_, __) {},
                    child: widget.post.profileImageUrl.isEmpty
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        // Show whether this is a company or personal post
                        Text(
                          widget.post.companyId != null
                              ? 'Company Post'
                              : 'Personal Post',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 4.h),
              
              // Post content text field
              TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'What do you want to talk about?',
                  hintStyle: TextStyle(color: AppColors.gray, fontSize: 16.sp),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16.sp, height: 1.4),
                onChanged: (_) => setState(() {}),
              ),
              
              SizedBox(height: 2.h),
              
              // Show existing attachment if any (read-only)
              if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: Colors.yellow[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.yellow[800],
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Attachments cannot be edited. To change attachments, delete this post and create a new one.',
                          style: TextStyle(
                            color: Colors.yellow[900],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Show the current attachment (read-only)
                Container(
                  width: double.infinity,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                    image: DecorationImage(
                      image: NetworkImage(widget.post.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updatePost() async {
    if (_contentController.text.isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final success = await ref.read(homeViewModelProvider.notifier).editPost(
        widget.post.id,
        _contentController.text,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully')),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post')),
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