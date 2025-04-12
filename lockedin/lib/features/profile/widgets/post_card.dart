import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../home_page/model/post_model.dart';
import 'package:lockedin/shared/theme/colors.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onNotInterested;
  final VoidCallback? onReport;

  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    this.onSaveForLater,
    this.onNotInterested,
    this.onReport,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100.w,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// User Info Row with Three-Dot Menu
              Row(
                children: [
                  // Profile image with error handling
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.profileImageUrl),
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint('Error loading profile image: $exception');
                    },
                    radius: 2.5.h,
                    // Fallback when image fails to load
                    child:
                        post.profileImageUrl.isEmpty
                            ? Icon(Icons.person, size: 3.h)
                            : null,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Username with overflow handling
                            Flexible(
                              child: Text(
                                post.username,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            TextButton(
                              onPressed: onFollow,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 1.w),
                                minimumSize: Size(0, 3.h),
                              ),
                              child: Text(
                                "• Follow",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Time info with null safety
                        Text(
                          "${post.time.isNotEmpty ? post.time : 'Just now'} ${post.isEdited ? '· Edited' : ''}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.gray,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Three-dot menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 2.5.h,
                      color: theme.iconTheme.color,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'save':
                          onSaveForLater?.call();
                          break;
                        case 'not_interested':
                          onNotInterested?.call();
                          break;
                        case 'report':
                          onReport?.call();
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'save',
                            height: 5.h,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark_border,
                                  size: 2.h,
                                  color: theme.iconTheme.color,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Save for later',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'not_interested',
                            height: 5.h,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.not_interested,
                                  size: 2.h,
                                  color: theme.iconTheme.color,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Not interested',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'report',
                            height: 5.h,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 2.h,
                                  color: theme.iconTheme.color,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Report this post',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),

              // Content with null safety
              SizedBox(height: 1.5.h),
              Text(
                post.content.isNotEmpty ? post.content : 'No content',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),

              // Image with loading and error handling
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                SizedBox(height: 1.5.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(1.h),
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    width: 100.w,
                    height: 25.h,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100.w,
                        height: 25.h,
                        color: theme.cardColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading post image: $error');
                      return Container(
                        width: 100.w,
                        height: 15.h,
                        color: theme.cardColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 5.h,
                                color: AppColors.gray,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Image could not be loaded',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Engagement statistics
              SizedBox(height: 1.h),
              Row(
                children: [
                  if (post.likes > 0) ...[
                    Icon(Icons.thumb_up, size: 2.h, color: AppColors.gray),
                    SizedBox(width: 1.w),
                    Text(
                      '${post.likes}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.gray,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 3.w),
                  ],
                  Spacer(),
                  if (post.comments > 0) ...[
                    Text(
                      '${post.comments} comments .',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.gray,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],

                  if (post.reposts > 0) ...[
                    Text(
                      '${post.reposts} reposts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.gray,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ],
              ),

              // Divider
              SizedBox(height: 0.5.h),
              Divider(
                height: 0.1.h,
                thickness: 0.1.h,
                color: AppColors.gray.withOpacity(0.3),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.only(top: 0.7.h, bottom: 0.2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like button
                    TextButton(
                      onPressed: onLike,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 2.5.h,
                            color: theme.iconTheme.color,
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Like',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Comment button
                    TextButton(
                      onPressed: onComment,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 2.5.h,
                            color: theme.iconTheme.color,
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Comment',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Repost button
                    TextButton(
                      onPressed: () {
                        // Add functionality for reposting here
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 2.5.h,
                            color: theme.iconTheme.color,
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Repost',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Share button
                    TextButton(
                      onPressed: onShare,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.send,
                            size: 2.5.h,
                            color: theme.iconTheme.color,
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Share',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
