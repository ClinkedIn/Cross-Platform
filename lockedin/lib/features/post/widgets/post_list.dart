import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import '../../home_page/model/post_model.dart';
import '../../home_page/viewModel/home_viewmodel.dart';
import 'post_card.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

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

  void _scrollListener() {
    // Load more posts when user scrolls to 80% of the list
    if (widget.hasMorePages &&
        !widget.isLoadingMore &&
        _scrollController.position.pixels >
            _scrollController.position.maxScrollExtent * 0.8) {
      widget.onLoadMore?.call();
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
      controller:
          _scrollController, // Fixed: Added the controller to the ListView
      itemCount: widget.posts.length + 1, // Fixed: Added widget. prefix
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
                    : Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Center(
                        child: Text(
                          'No more posts to load',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
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
            try {
              final userState = ref.watch(userProvider);
              var userid = userState.when(
                data: (user) => user.id,
                error: (error, stackTrace) => null,
                loading: () => null,
              );
              await ref
                  .read(homeViewModelProvider.notifier)
                  .toggleRepost(widget.posts[index].id, userid ?? '');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: userState.when(
                      data:
                          (user) =>
                              widget.posts[index].reposterId == user.id
                                  ? Text('Repost removed')
                                  : Text('Post reposted successfully'),
                      error: (error, stackTrace) => Text('Error: $error'),
                      loading: () => CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            } catch (e) {
              print("Error reposting: $e");
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          onComment: () {
            print("Commented on post: ${widget.posts[index].id}");
            print("number of comments: ${widget.posts[index].comments}");
            context.push('/detailed-post/${widget.posts[index].id}');
          },
          onShare: () async {
            print("Shared post: ${widget.posts[index].id}");
            context.push('/create-repost', extra: widget.posts[index]);
            // Share functionality...
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
