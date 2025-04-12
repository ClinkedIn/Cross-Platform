import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/colors.dart';
import '../viewmodel/post_viewmodel.dart';
import '../state/post_state.dart';

class PostPage extends ConsumerWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final postState = ref.watch(postViewModelProvider);
    final postViewModel = ref.read(postViewModelProvider.notifier);
    
    // Create a TextEditingController that updates the ViewModel when text changes
    final textController = TextEditingController(text: postState.content);
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );
    
    // Show error if one exists
    if (postState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: postViewModel.clearError,
            ),
          ),
        );
        postViewModel.clearError();
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          postState.isSubmitting
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 2.h,
              width: 2.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
        : FilledButton(
            onPressed: postState.canSubmit
                ? () async {
                    final success = await postViewModel.submitPost();
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: postState.canSubmit 
                  ? AppColors.primary 
                  : AppColors.gray.withOpacity(0.5),
              disabledBackgroundColor: AppColors.gray.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 5.w),
            ),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.white, // Always white text for contrast
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
            ],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile info
              Row(
                children: [
                  CircleAvatar(
                    radius: 6.w,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/300', // Replace with user's profile image
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: const Icon(Icons.person),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: // Add this to your existing ViewModel or create a new state variable for visibility
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: postState.visibility ?? 'Anyone', // Add this field to your state
                                isDense: true,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.gray,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'Anyone',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.public,
                                          size: 4.w,
                                          color: AppColors.gray,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'Anyone',
                                          style: TextStyle(
                                            color: AppColors.gray,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Connections',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 4.w,
                                          color: AppColors.gray,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'Connections',
                                          style: TextStyle(
                                            color: AppColors.gray,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  postViewModel.updateVisibility(value!);
                                },
                              ),
                            ),
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
                controller: textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'What do you want to talk about?',
                  hintStyle: TextStyle(
                    color: AppColors.gray,
                    fontSize: 16.sp,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.4,
                ),
                onChanged: postViewModel.updateContent,
              ),
              
              SizedBox(height: 2.h),
              
              // Selected image preview
              if (postState.imageFile != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.w),
                      child: Image.file(
                        postState.imageFile!,
                        width: 100.w,
                        height: 40.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 1.h,
                      right: 1.h,
                      child: InkWell(
                        onTap: postViewModel.removeImage,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 5.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.gray.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: postViewModel.pickImage,
              icon: Icon(Icons.image, color: AppColors.primary),
              tooltip: 'Add image',
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video upload not implemented yet')),
                );
              },
              icon: Icon(Icons.videocam, color: AppColors.primary),
              tooltip: 'Add video',
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document upload not implemented yet')),
                );
              },
              icon: Icon(Icons.document_scanner, color: AppColors.primary),
              tooltip: 'Add document',
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emoji picker not implemented yet')),
                );
              },
              icon: Icon(Icons.emoji_emotions_outlined, color: AppColors.primary),
              tooltip: 'Add emoji',
            ),
          ],
        ),
      ),
    );
  }
}