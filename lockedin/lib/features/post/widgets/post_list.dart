import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import '../../home_page/model/post_model.dart';
import '../../home_page/viewModel/home_viewmodel.dart';
import 'post_card.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/home_page/view/post_sharing_service.dart';

class PostList extends ConsumerStatefulWidget {
  final List<PostModel> posts;
  final bool isLoadingMore;
  final bool hasMorePages;
  final VoidCallback? onLoadMore;

  const PostList({
    required this.posts,
    this.isLoadingMore = false,
    this.hasMorePages = false,
    this.onLoadMore,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PostList> createState() => _PostListState();
}

class _PostListState extends ConsumerState<PostList> {
  final ScrollController _scrollController = ScrollController();

  // void _safelyCheckScroll() {
  //   if (!mounted) return;

  //   try {
  //     _scrollListener();
  //   } catch (e) {
  //     debugPrint('Error in scroll listener: $e');
  //     // Prevent further errors by removing listener if there's a problem
  //     if (e.toString().contains('ScrollController not attached')) {
  //       _scrollController.removeListener(_scrollListener);
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  void _scrollListener() {
    // Don't process if already loading
    if (_isLoading || widget.isLoadingMore) return;

    // Check if we have a scroll position yet
    if (!_scrollController.hasClients) return;

    // Calculate load threshold (closer to bottom)
    final threshold = _scrollController.position.maxScrollExtent * 0.9;

    // Debug log to track scroll position
    // debugPrint('Scroll: ${_scrollController.position.pixels}/$threshold');

    if (widget.hasMorePages && _scrollController.position.pixels > threshold) {
      _isLoading = true;

      // Add short delay to prevent rapid firing on momentum scrolls
      Future.microtask(() {
        widget.onLoadMore?.call();
        // Reset local loading flag after a delay
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty state
    if (widget.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Posts from your network will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      // Add these performance optimizations:
      addAutomaticKeepAlives: false,
      itemCount: widget.posts.length + (widget.hasMorePages ? 1 : 0),
      // Add cacheExtent to preload more items
      cacheExtent: 500,
      itemBuilder: (context, index) {
        // Show Load More button or loading indicator at the bottom
        if (index == widget.posts.length) {
          // Fixed: Added widget. prefix
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child:
                widget
                        .isLoadingMore // Fixed: Added widget. prefix
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : widget
                        .hasMorePages // Fixed: Added widget. prefix
                    ? ElevatedButton(
                      onPressed:
                          widget.onLoadMore, // Fixed: Added widget. prefix
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Load More Posts',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    // Replace the "No more posts" section with:
                    : !widget.hasMorePages
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Center(
                        child: Column(
                          children: [
                            Divider(),
                            SizedBox(height: 8),
                            Text(
                              'You\'ve reached the end',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                // Scroll back to top when user reaches the end
                                _scrollController.animateTo(
                                  0,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: Icon(Icons.arrow_upward, size: 16),
                              label: Text('Back to top'),
                            ),
                          ],
                        ),
                      ),
                    )
                    : SizedBox.shrink(), // Fixed: Added widget. prefix
          );
        }

        // Regular post card with all existing functionality
        return PostCard(
          post: widget.posts[index],
          // All other properties remain the same
          onEdit:
              widget.posts[index].isMine
                  ? () {
                    context.push('/edit-post', extra: widget.posts[index]);
                    print("Editing post: ${widget.posts[index].id}");
                  }
                  : null,
          onDelete:
              (widget.posts[index].isMine &&
                      widget.posts[index].userId.isNotEmpty)
                  ? () async {
                    final delete = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Post'),
                            content: Text(
                              'Are you sure you want to delete this post?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                    // If user confirmed, delete the post
                    if (delete == true) {
                      try {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .deletePost(widget.posts[index].id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Post deleted successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete post: $e'),
                            ),
                          );
                        }
                      }
                    }

                    print("Deleting post: ${widget.posts[index].id}");
                  }
                  : null,
          onLike: () async {
            try {
              await ref
                  .read(homeViewModelProvider.notifier)
                  .toggleLike(widget.posts[index].id);
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
          onRepost: () async {
            // Show a bottom sheet with two repost options
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder:
                  (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Repost Options',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(height: 1),
                      // Option 1: Quick Repost
                      ListTile(
                        leading: Icon(Icons.repeat, color: AppColors.primary),
                        title: Text('Quick Repost'),
                        subtitle: Text(
                          'Repost without adding your own content',
                        ),
                        onTap: () async {
                          Navigator.pop(context); // Close the bottom sheet
                          try {
                            final userState = ref.watch(userProvider);
                            var userid = userState.when(
                              data: (user) => user.id,
                              error: (error, stackTrace) => null,
                              loading: () => null,
                            );

                            await ref
                                .read(homeViewModelProvider.notifier)
                                .toggleRepost(
                                  widget.posts[index].id,
                                  userid ?? '',
                                );

                            print(
                              "Quick repost for post: ${widget.posts[index].id}",
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: userState.when(
                                    data:
                                        (user) =>
                                            widget.posts[index].isRepost ==
                                                        true &&
                                                    widget
                                                            .posts[index]
                                                            .repostId ==
                                                        user.id
                                                ? Text('Repost removed')
                                                : Text(
                                                  'Post reposted successfully',
                                                ),
                                    error:
                                        (error, stackTrace) =>
                                            Text('Error: $error'),
                                    loading: () => CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Error reposting: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),
                      // Option 2: Repost with Content
                      ListTile(
                        leading: Icon(
                          Icons.mode_edit_outline,
                          color: AppColors.primary,
                        ),
                        title: Text('Repost with Comment'),
                        subtitle: Text('Add your own thoughts when reposting'),
                        onTap: () {
                          Navigator.pop(context); // Close the bottom sheet
                          // Navigate to create-repost page
                          context.push(
                            '/create-repost',
                            extra: widget.posts[index],
                          );
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
            );
          },
          onComment: () {
            print("Commented on post: ${widget.posts[index].id}");
            print("number of comments: ${widget.posts[index].comments}");
            context.push('/detailed-post/${widget.posts[index].id}');
          },
          onShare: () async {
            // Generate a shareable link for the post
            final String postLink = PostSharingService.generatePostLink(
              widget.posts[index].id,
            );

            // Show a bottom sheet with sharing options
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder:
                  (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Share Post',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(height: 1),
                      // Option 1: Share via native share sheet
                      // Option 1: Share via native share sheet
                      ListTile(
                        leading: Icon(Icons.share, color: AppColors.primary),
                        title: Text('Share to apps'),
                        subtitle: Text('Share via other apps on your device'),
                        onTap: () async {
                          Navigator.pop(context); // Close bottom sheet first

                          // Use the service implementation instead of inline implementation
                          await PostSharingService.sharePost(
                            postId: widget.posts[index].id,
                            postContent: widget.posts[index].content,
                            context: context,
                          );
                        },
                      ),
                      // Option 2: Copy link to clipboard
                      ListTile(
                        leading: Icon(Icons.link, color: AppColors.primary),
                        title: Text('Copy link'),
                        subtitle: Text('Copy post link to clipboard'),
                        onTap: () async {
                          Navigator.pop(context); // Close bottom sheet

                          try {
                            await Clipboard.setData(
                              ClipboardData(text: postLink),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Link copied to clipboard'),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('Error copying link: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to copy link')),
                              );
                            }
                          }
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
            );
          },
          onFollow: () {
            print("Followed ${widget.posts[index].username}");
          },
          onSaveForLater: () async {
            // Call the savePostById function with the post's ID
            try {
              final success = await ref
                  .read(homeViewModelProvider.notifier)
                  .toggleSaveForLater(widget.posts[index].id);
              if (success && context.mounted) {
                // Optionally show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.posts[index].isSaved == true
                          ? 'Post removed from saved items'
                          : 'Post saved for later',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              // Show error message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
            print("Saved post: ${widget.posts[index].id}");
          },
          onReport: () async {
            // Define the report reasons based on backend validation
            final List<String> reportReasons = [
              // General content violations
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
              // User-specific violations
              "This person is impersonating someone",
              "This account has been hacked",
              "This account is not a real person",
            ];

            // Show a dialog to choose the report reason
            final selectedReason = await showDialog<String>(
              context: context,
              builder:
                  (context) => AlertDialog(
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
                                  onTap:
                                      () => Navigator.pop(
                                        context,
                                        reportReasons[index],
                                      ),
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
                await ref
                    .read(homeViewModelProvider.notifier)
                    .reportPost(widget.posts[index].id, selectedReason);

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

            print("Reported post: ${widget.posts[index].id}");
          },
          onNotInterested: () {
            // Not interested functionality...
          },
        );
      },
    );
  }
}
