import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/post/viewmodel/post_viewmodel.dart';
import 'package:video_player/video_player.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  // Mock state for UI demonstration only
  late TextEditingController textController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    // Initialize any state or controllers here if needed
    final initialData = ref.read(postViewModelProvider);
    if (initialData.content.isNotEmpty) {
      textController.text = initialData.content;
    }

    // Initialize video controller if video is already selected
    if (initialData.attachments != null &&
        initialData.attachments!.isNotEmpty &&
        initialData.fileType == 'video') {
      _initializeVideoController(initialData.attachments!.first);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Initialize video controller
  void _initializeVideoController(File videoFile) {
    _videoController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        // Ensure the first frame is shown
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      });
  }

  // Add this method to your _PostPageState class
  IconData _getDocumentIcon(String path) {
    final extension = path.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Listen for changes in the selected file
  @override
  void didUpdateWidget(covariant PostPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final data = ref.read(postViewModelProvider);
    if (data.attachments != null &&
        data.attachments!.isNotEmpty &&
        data.fileType == 'video') {
      // If the file is a video and we don't have a controller or it's for a different file
      if (_videoController == null ||
          _videoController!.dataSource !=
              'file://${data.attachments!.first.path}') {
        _videoController?.dispose();
        _initializeVideoController(data.attachments!.first);
      }
    } else if (_videoController != null) {
      // If we have a controller but no video file selected anymore
      _videoController!.dispose();
      _videoController = null;
      _isVideoInitialized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = ref.watch(postViewModelProvider);
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          data.isSubmitting
              ? Padding(
                padding: EdgeInsets.all(2.w),
                child: SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 0.5.w,
                  ),
                ),
              )
              : // Replace the current "Post" button with this:
                FilledButton(
                  onPressed: data.canSubmit
                      ? () async {
                          // Submit the post
                          await ref
                              .read(postViewModelProvider.notifier)
                              .submitPost(
                                content: textController.text,
                                attachments: data.attachments ?? [],
                                visibility: data.visibility,
                              );
                          
                          // Reset all state
                          ref.read(postViewModelProvider.notifier).resetState();
                          
                          // Clear the text controller
                          textController.clear();
                          
                          // Reset video player if active
                          if (_videoController != null) {
                            _videoController!.dispose();
                            _videoController = null;
                            _isVideoInitialized = false;
                          }
                          
                          // Navigate to home page
                          context.go('/home');
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: data.canSubmit
                        ? AppColors.primary
                        : AppColors.gray.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.white,
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
                    backgroundImage: userState.whenOrNull(
                      data:
                          (user) =>
                              user.profilePicture != null &&
                                      user.profilePicture!.isNotEmpty
                                  ? NetworkImage(user.profilePicture!)
                                  : AssetImage(
                                    'assets/images/default_profile_photo.png',
                                  ),
                    ),
                    backgroundColor: Colors.grey[300],
                    onBackgroundImageError: (_, __) {},
                    child: userState.when(
                      data:
                          (user) =>
                              (user.profilePicture == null ||
                                      user.profilePicture!.isEmpty)
                                  ? Icon(Icons.person, color: Colors.white)
                                  : null,
                      error: (_, __) => Icon(Icons.person, color: Colors.white),
                      loading: () => Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.gray.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.gray.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: data.visibility,
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
                                  if (value != null) {
                                    ref
                                        .read(postViewModelProvider.notifier)
                                        .updateVisibility(value);
                                  }
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
              // Tagged users chips
              if (data.taggedUsers.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Wrap(
                    spacing: 1.w,
                    runSpacing: 0.5.h,
                    children:
                        data.taggedUsers.map((user) {
                          return Chip(
                            backgroundColor: theme.primaryColor.withOpacity(
                              0.1,
                            ),
                            avatar: CircleAvatar(
                              backgroundImage:
                                  user.profilePicture != null &&
                                          user.profilePicture!.isNotEmpty
                                      ? NetworkImage(user.profilePicture!)
                                      : null,
                              child:
                                  (user.profilePicture == null ||
                                          user.profilePicture!.isEmpty)
                                      ? Icon(Icons.person, size: 1.5.h)
                                      : null,
                            ),
                            label: Text(
                              '${user.firstName} ${user.lastName}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            deleteIcon: Icon(Icons.close, size: 1.5.h),
                            onDeleted:
                                () => ref
                                    .read(postViewModelProvider.notifier)
                                    .removeTaggedUser(user.userId),
                          );
                        }).toList(),
                  ),
                ),
              // Post content text field
              TextField(
                controller: textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'What do you want to talk about?',
                  hintStyle: TextStyle(color: AppColors.gray, fontSize: 16.sp),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16.sp, height: 1.4),
                onChanged: (text) {
                  // Just for UI updates
                  ref
                      .read(postViewModelProvider.notifier)
                      .updateContent(text, textController);
                  setState(() {});
                },
              ),

              // User mention suggestions overlay
              if (data.showMentionSuggestions &&
                  data.userSearchResults.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  constraints: BoxConstraints(maxHeight: 30.h),
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
                  child:
                      data.isSearchingUsers
                          ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.userSearchResults.length,
                            itemBuilder: (context, index) {
                              final user = data.userSearchResults[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.h,
                                  vertical: 0.5.h,
                                ),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      user.profilePicture != null &&
                                              user.profilePicture!.isNotEmpty
                                          ? NetworkImage(user.profilePicture!)
                                          : null,
                                  child:
                                      (user.profilePicture == null ||
                                              user.profilePicture!.isEmpty)
                                          ? Icon(Icons.person)
                                          : null,
                                ),
                                title: Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    user.headline != null &&
                                            user.headline!.isNotEmpty
                                        ? Text(
                                          user.headline!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                        : null,
                                onTap:
                                    () => ref
                                        .read(postViewModelProvider.notifier)
                                        .onMentionSelected(
                                          user,
                                          textController,
                                        ),
                              );
                            },
                          ),
                ),

              SizedBox(height: 2.h),

              // Media preview section when attachments exist
              if (data.attachments != null && data.attachments!.isNotEmpty)
                for (var file in data.attachments!)
                  Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: AppColors.gray.withOpacity(0.3),
                          ),
                        ),
                        child:
                            data.fileType == 'document'
                                ? Container(
                                  padding: EdgeInsets.all(3.w),
                                  height: 15.h,
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      // Document icon based on file extension
                                      Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            1.w,
                                          ),
                                        ),
                                        child: Icon(
                                          _getDocumentIcon(file.path),
                                          size: 8.w,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      // Document details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              file.path.split('/').last,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : data.fileType == 'video'
                                ? Container(
                                  height: 30.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(2.w),
                                  ),
                                  child:
                                      _isVideoInitialized &&
                                              _videoController != null
                                          ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(2.w),
                                                child: AspectRatio(
                                                  aspectRatio:
                                                      _videoController!
                                                          .value
                                                          .aspectRatio,
                                                  child: VideoPlayer(
                                                    _videoController!,
                                                  ),
                                                ),
                                              ),
                                              // Play button overlay
                                              IconButton(
                                                icon: Icon(
                                                  _videoController!
                                                          .value
                                                          .isPlaying
                                                      ? Icons
                                                          .pause_circle_filled
                                                      : Icons
                                                          .play_circle_filled,
                                                  color: Colors.white,
                                                  size: 15.w,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _videoController!
                                                            .value
                                                            .isPlaying
                                                        ? _videoController!
                                                            .pause()
                                                        : _videoController!
                                                            .play();
                                                  });
                                                },
                                              ),
                                              // Video duration indicator
                                              Positioned(
                                                bottom: 1.h,
                                                right: 2.w,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                    vertical: 0.5.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.w,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    _formatDuration(
                                                      _videoController!
                                                          .value
                                                          .duration,
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                          : Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(2.w),
                                  child: Image.file(
                                    file,
                                    height: 30.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      ),
                      Positioned(
                        right: 1.w,
                        top: 1.w,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(postViewModelProvider.notifier)
                                .removeAttachment();
                            _videoController?.dispose();
                            _videoController = null;
                            _isVideoInitialized = false;
                          },
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.gray.withOpacity(0.2), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                ref.read(postViewModelProvider.notifier).pickImage();
              },
              icon: Icon(Icons.image, color: AppColors.primary),
              tooltip: 'Add image',
            ),
            IconButton(
              onPressed: () {
                ref.read(postViewModelProvider.notifier).pickVideo();
              },
              icon: Icon(Icons.videocam, color: AppColors.primary),
              tooltip: 'Add video',
            ),
            IconButton(
              onPressed: () {
                ref.read(postViewModelProvider.notifier).pickDocument();
              },
              icon: Icon(Icons.document_scanner, color: AppColors.primary),
              tooltip: 'Add document',
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                // No functionality
              },
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: AppColors.primary,
              ),
              tooltip: 'Add emoji',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format video duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
