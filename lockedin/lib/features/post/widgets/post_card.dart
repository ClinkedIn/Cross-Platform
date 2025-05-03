import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:sizer/sizer.dart';
import '../../home_page/model/post_model.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../widgets/videoplayer_view.dart';
import '../../home_page/repository/posts/comment_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

    
//some helper functions for media handling
// Add this at the top of the file, after your imports
    enum MediaType { image, video, document, unknown }

    // Add these helper functions after the PostCard class
       String _getFileExtension(String url) {
        // Check if it's a Google Docs viewer URL
          if (url.startsWith('https://docs.google.com/viewer')) {
            try {
              // Extract the original URL from the 'url' parameter
              final uri = Uri.parse(url);
              final originalUrl = uri.queryParameters['url'];
              if (originalUrl != null) {
                return _getFileExtension(Uri.decodeComponent(originalUrl));
              }
            } catch (e) {
              print('Error extracting original URL: $e');
            }
          }
          // Remove query parameters
          String cleanUrl = url.split('?').first;
          
          // Extract the filename
          List<String> pathSegments = Uri.parse(cleanUrl).pathSegments;
          if (pathSegments.isEmpty) return '';
          
          String filename = pathSegments.last;
          List<String> parts = filename.split('.');
          
          // Return the extension if found
          return parts.length > 1 ? parts.last.toLowerCase() : '';
        }

    String _getFileName(String url) {
      // Check if it's a Google Docs viewer URL
        if (url.startsWith('https://docs.google.com/viewer')) {
          try {
            // Extract the original URL from the 'url' parameter
            final uri = Uri.parse(url);
            final originalUrl = uri.queryParameters['url'];
            if (originalUrl != null) {
              return _getFileName(Uri.decodeComponent(originalUrl));
            }
          } catch (e) {
            print('Error extracting original URL: $e');
          }
        }

      final segments = Uri.parse(url).pathSegments;
      return segments.isNotEmpty ? segments.last.split('?').first : 'Document';
    }

    Color _getDocumentColor(String url) {
      final extension = _getFileExtension(url).toLowerCase();
      
      switch (extension) {
        case 'pdf':
          return Colors.red[700]!;
        case 'doc':
        case 'docx':
          return Colors.blue[700]!;
        case 'xls':
        case 'xlsx':
          return Colors.green[700]!;
        case 'ppt':
        case 'pptx':
          return Colors.orange[700]!;
        default:
          return Colors.grey[700]!;
      }
    }

    MediaType _getMediaType(String url, {String? explicitType}) {
      if (explicitType != null) {
        switch (explicitType) {
          case 'image': return MediaType.image;
          case 'video': return MediaType.video;
          case 'document': return MediaType.document;
          default: break;
        }
      }

      // Check if it's a Google Docs viewer URL
        if (url.startsWith('https://docs.google.com/viewer')) {
          return MediaType.document;
        }
      
      final extension = _getFileExtension(url).toLowerCase();
      
      // Image formats
      if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
        return MediaType.image;
      }
      
      // Video formats
      else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
        return MediaType.video;
      }
      
      // Document formats
      else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
        return MediaType.document;
      }
      
      // Unknown format
      return MediaType.unknown;
    }

class PostCard extends ConsumerWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onRepost;
  final VoidCallback onFollow;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onNotInterested;
  final VoidCallback? onReport;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onRepost,
    this.onSaveForLater,
    this.onNotInterested,
    this.onReport,
    this.onEdit,
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);

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
             // reposter information
              if (post.isRepost == true) ...[
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reposter's profile image
                  if (post.reposterProfilePicture != null && post.reposterProfilePicture!.isNotEmpty) 
                    CircleAvatar(
                      backgroundImage: NetworkImage(post.reposterProfilePicture!),
                      radius: 1.7.h,
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Error loading reposter profile image: $exception');
                      },
                      child: post.reposterProfilePicture!.isEmpty
                          ? Icon(Icons.person, size: 2.5.h)
                          : null,
                    )
                  else
                    CircleAvatar(
                      radius: 1.h,
                      child: Icon(Icons.person, size: 2.5.h),
                    ),
                  SizedBox(width: 1.5.w),
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: post.isMine ? 'You' : (post.reposterName ?? 'Someone'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // If it's your repost, go to your profile
                                    if (post.isMine) {
                                      context.push('/profile');
                                    } 
                                    // Otherwise go to reposter's profile if ID exists
                                    else  {
                                      context.push('/other-profile/${post.reposterId}');
                                    }
                                  },
                              ),
                              TextSpan(
                                text: ' reposted this',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                         // Show repost description if available
                        if (post.repostDescription != null && post.repostDescription!.isNotEmpty) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            post.repostDescription!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Divider(
                height: 0.1.h,
                thickness: 0.1.h,
                color: AppColors.gray.withOpacity(0.3),
              ),
              SizedBox(height: 1.h),
            ],

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
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Username with overflow handling
                              Flexible(
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to appropriate profile
                                  if (post.isMine) {
                                    // Navigate to user's own profile
                                    context.push('/profile');
                                  } else if (post.userId.isNotEmpty) {
                                    // Navigate to other user's profile
                                    context.push('/other-profile/${post.userId}');
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft,
                                ),
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
                            ),
                          ],
                        ),
                        if (post.userId.isEmpty && post.companyId != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 1.8.h,
                                color: AppColors.gray,
                              ),
                              SizedBox(width: 0.2.h),
                              Expanded(
                                child: Text(
                                  [
                                    post.companyId?['industry'],
                                    post.companyId?['organizationSize'],
                                    post.companyId?['organizationType'],
                                  ].where((e) => e != null && e.toString().isNotEmpty).join(' • '),
                                  style: TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 15.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                      ] else ...[// Regular user post time info
                          Text(
                            "${post.time.isNotEmpty ? post.time : 'Just now'} ${post.isEdited ? '· Edited' : ''}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
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
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;    
                      }
                    },
                    itemBuilder:
                        (context) => post.isMine ?[
                      PopupMenuItem(
                          value: 'edit',
                          height: 5.h,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 2.h,
                                color: theme.iconTheme.color,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Edit post',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                          value: 'delete',
                          height: 5.h,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 2.h,
                                color: theme.iconTheme.color,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Delete post',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                       // Menu options for other people's posts
                        : [
                        PopupMenuItem(
                          value: 'save',
                          height: 5.h,
                          child: Row(
                            children: [
                              Icon(
                                post.isSaved == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 2.h,
                                color: post.isSaved == true
                                    ? AppColors.primary
                                    : theme.iconTheme.color,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                post.isSaved == true ? 'Unsave post' : 'Save for later',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                  color: post.isSaved == true ? AppColors.primary : null,
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
             // Image/media with advanced handling
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                SizedBox(height: 1.5.h),
                _buildMediaContent(
                  context: context,
                  url: post.imageUrl!,
                  mediaType: _getMediaType(post.imageUrl!, explicitType: post.mediaType),
                  theme: theme,
                ),
              ],
              // Engagement statistics
              SizedBox(height: 1.h),
              Row(
                children: [
                  if (post.likes > 0) ...[
                    InkWell(
                      onTap: () {
                        // Navigate to the likes list page
                        context.push('/post-likes/${post.id}');
                      },
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up, size: 2.h, color: AppColors.gray),
                          SizedBox(width: 1.w),
                          Text(
                            '${post.likes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                  ],
                  Spacer(),
                  if (post.comments > 0) ...[
                    TextButton(
                      onPressed: () {
                        // Navigate to detailed post view, same as comment button
                        context.push('/detailed-post/${post.id}');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        '${post.comments} comments .',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],

                  if (post.reposts > 0) ...[
                   
                    TextButton(
                      onPressed: () {
                        // If there are reposts, navigate to the repost list
                        if (post.reposts > 0) {
                          context.go('/post-reposts/${post.id}');
                        } else {
                          // If no reposts, just call the regular onRepost callback
                          onRepost();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        minimumSize: Size(0, 4.h),
                      ),
                      child:  Text(
                        '${post.reposts} Reposts ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                          fontSize: 15.sp,
                        ),
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
                            // Use == true to safely handle potential null values
                            post.isLiked == true
                                ? Icons.thumb_up
                                : Icons.thumb_up_alt_outlined,
                            size: 2.5.h,
                            color:
                                post.isLiked == true
                                    ? AppColors.primary
                                    : theme.iconTheme.color,
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Like',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15.sp,
                              color:
                                  post.isLiked == true
                                      ? AppColors.primary
                                      : null,
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

                    // Repost button - update with proper condition
                    TextButton(
                      onPressed: onRepost,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Column(
                        children: [
                          userState.when(
                            data: (user) {
                              // Determine if the post has been reposted by the current user
                              final bool isMyRepost = post.isRepost == true && post.reposterId == user.id;
                              
                              // Determine if this is the user's own post that has been reposted
                              final bool isMyPostReposted = post.isMine == true && post.isRepost == true;
                              
                              // Debug
                              if (post.isRepost == true) {
                                debugPrint('Post ${post.id} - isRepost: ${post.isRepost}, isMine: ${post.isMine}, reposterId: ${post.reposterId}, userId: ${user.id}, isMyRepost: $isMyRepost, isMyPostReposted: $isMyPostReposted');
                              }
                              
                              return Icon(
                                // Use either condition to show the reposted icon
                                (isMyRepost || isMyPostReposted) ? Icons.repeat_one : Icons.repeat,
                                size: 2.5.h,
                                color: (isMyRepost || isMyPostReposted) ? AppColors.green : theme.iconTheme.color,
                              );
                            },
                            error: (error, stackTrace) => Icon(
                              Icons.repeat,
                              size: 2.5.h,
                              color: theme.iconTheme.color,
                            ),
                            loading: () => SizedBox(
                              width: 2.5.h,
                              height: 2.5.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          userState.when(
                            data: (user) {
                              // Use the same conditions for the text
                              final bool isMyRepost = post.isRepost == true && post.reposterId == user.id;
                              final bool isMyPostReposted = post.isMine == true && post.isRepost == true;
                              
                              return Text(
                                (isMyRepost || isMyPostReposted) ? 'Reposted' : 'Repost',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                  color: (isMyRepost || isMyPostReposted) ? AppColors.green : theme.iconTheme.color,
                                ),
                              );
                            },
                            error: (error, stackTrace) => Text(
                              'Repost',
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
                            ),
                            loading: () => Text(
                              'Repost',
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
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

  Widget _buildMediaContent({
    required BuildContext context, 
    required String url, 
    required MediaType mediaType,
    required ThemeData theme,
  }) {
  //    print('URL: $url');
  // print('Explicit media type: ${post.mediaType}'); // Note: This might cause an error if post is not accessible
  // final extension = _getFileExtension(url);
  // print('Detected extension: $extension');
  // MediaType detectedType = _getMediaType(url, explicitType: post.mediaType); // Same issue with post.mediaType
  // print('Detected media type: $detectedType');
    switch (mediaType) {
      case MediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(1.h),
          child: Image.network(
            url,
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
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image: $error');
              return _buildErrorContainer(context, theme, 'Image could not be loaded');
            },
          ),
        );
        
      case MediaType.video:
      return VideoPlayerWidget(url: url);
        
      case MediaType.document:
        return InkWell(
          onTap: () {
            _showDocumentViewer(context, url);
          },
          child: Container(
            width: 100.w,
            height: 15.h,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(1.h),
              border: Border.all(color: AppColors.gray.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 15.w,
                  height: double.infinity,
                  color: _getDocumentColor(url),
                  child: Center(
                    child: Text(
                      _getFileExtension(url).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getFileName(url),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_getFileExtension(url).toUpperCase()} Document',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 2.h,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'View document',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
        );
        
        
      case MediaType.unknown:

        print('URL: $url');
        print('Explicit media type: ${post.mediaType}'); // Note: This might cause an error if post is not accessible
        final extension = _getFileExtension(url);
        print('Detected extension: $extension');
        MediaType detectedType = _getMediaType(url, explicitType: post.mediaType); // Same issue with post.mediaType
        print('Detected media type: $detectedType');
        // Try to preview the URL rather than just showing an error
        return _buildGenericUrlPreview(context, url, theme);
    }
  }

  // Helper to create error containers
  Widget _buildErrorContainer(BuildContext context, ThemeData theme, String message) {
    return Container(
      width: 100.w,
      height: 15.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(1.h),
        border: Border.all(color: AppColors.gray.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 5.h, color: AppColors.gray),
            SizedBox(height: 1.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentViewer(BuildContext context, String documentUrl) {
    final String googleDocsUrl = documentUrl.startsWith('https://docs.google.com/viewer') 
        ? documentUrl 
        : 'https://docs.google.com/viewer?url=${Uri.encodeComponent(documentUrl)}&embedded=true';
  
  // For demo/testing, you can use your specific URL
  // final String googleDocsUrl = 'https://docs.google.com/viewer?url=https%3A%2F%2Fres.cloudinary.com%2Fdn9y17jjs%2Fraw%2Fupload%2Fv1744715643%2Fdocuments%2Fybhkvxvprn7t53gpi08w&embedded=true';
  
  print('Opening document with URL: $googleDocsUrl');
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2.h),
          topRight: Radius.circular(2.h),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2.h),
                topRight: Radius.circular(2.h),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Document Viewer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // WebView for document
          Expanded(
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(googleDocsUrl))
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (progress) {
                      if (progress < 100) {
                        print('Loading document: $progress%');
                      }
                    },
                    onPageFinished: (_) {
                      print('Document loaded successfully');
                    },
                    onWebResourceError: (error) {
                      print('Error loading document: ${error.description}');
                    },
                  ),
                ),
            ),
          ),
        ],
      ),
    ),
  );
}



  // Build a generic URL preview card
    Widget _buildGenericUrlPreview(BuildContext context, String url, ThemeData theme) {
      // Try to load the URL as an image first
      return ClipRRect(
        borderRadius: BorderRadius.circular(1.h),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 100.w,
          height: 25.h,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            
            // Show loading indicator while image loads
            return Container(
              width: 100.w,
              height: 25.h,
              color: theme.cardColor,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          // Only if image loading fails, show link preview
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Unable to load as image, showing link preview: $error');
            
            // Extract domain for display
            final Uri? uri = Uri.tryParse(url);
            final String domain = uri?.host ?? 'Unknown source';
            
            return InkWell(
              onTap: () {
                _launchUrl(context, url);
              },
              child: Container(
                width: 100.w,
                padding: EdgeInsets.all(2.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(1.h),
                  border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 2.5.h,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            domain,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      url,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.gray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Tap to open link',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

  // Launch URL in browser
  void _launchUrl(BuildContext context, String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri != null) {
      // You'll need to add the url_launcher package for this
      // For now, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening URL: $url')),
      );
      
      // When url_launcher is added:
      // launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL')),
      );
    }
  }
 // <-- End of class
}
