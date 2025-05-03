import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home_page/model/post_model.dart';
import '../../home_page/viewModel/home_viewmodel.dart';
import 'post_card.dart';
import 'package:sizer/sizer.dart';

class PostList extends ConsumerWidget {
  final List<PostModel> posts;

  const PostList({required this.posts, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: posts[index],
          // Add other existing properties...
            onEdit: posts[index].isMine ? () {
              // Implement edit functionality
              // Navigate to edit page, passing the post as extra data
              context.push('/edit-post', extra: posts[index]);
              print("Editing post: ${posts[index].id}");
              // Navigate to edit page or show edit dialog
            } : null,
            onDelete: (posts[index].isMine && posts[index].userId.isNotEmpty) ?() async {
              // Implement delete functionality
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
                 // If user confirmed, delete the post
                  if (delete == true) {
                    try {
                      await ref.read(homeViewModelProvider.notifier).deletePost(posts[index].id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post deleted successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete post: $e')),
                        );
                      }
                    }
                  }
                
              print("Deleting post: ${posts[index].id}");
              } : null,
              // Show confirmation dialog and delete if confirmed
          onLike: () async {
            try {
              await ref
                  .read(homeViewModelProvider.notifier)
                  .toggleLike(posts[index].id);
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
              await ref
                  .read(homeViewModelProvider.notifier)
                  .toggleRepost(posts[index].id);
              print("Repost button pressed for post: ${posts[index].id}");
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      posts[index].isRepost == true
                          ? 'Repost removed'
                          : 'Post reposted successfully',
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
            print("Commented on post: ${posts[index].id}");
            print("number of comments: ${posts[index].comments}");
            context.push('/detailed-post/${posts[index].id}');
          },
          onShare: () async {
            print("Shared post: ${posts[index].id}");
            //    String? description;

            // try {
            //   await ref.read(homeViewModelProvider.notifier).toggleRepost(
            //     posts[index].id,
            //     description: description,
            //   );
            //    // Show feedback to the user
            //     if (context.mounted) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(
            //             posts[index].isRepost
            //                 ? 'Repost removed'
            //                 : 'Post reposted successfully',
            //             style: TextStyle(color: Colors.black87),
            //           ),
            //                 backgroundColor: Colors.white,
            //         behavior: SnackBarBehavior.floating,
            //         margin: EdgeInsets.only(
            //           bottom: MediaQuery.of(context).size.height - 200,
            //           left: 10,
            //           right: 10
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //           side: BorderSide(color: Colors.grey.shade300),
            //         ),
            //       ),
            //     );
            //   }
            // } catch (e) {
            //   if (context.mounted) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text('Failed to repost: $e'),
            //           backgroundColor: Colors.red,
            //         ),
            //       );
            //     }
            //   }
          },
          onFollow: () {
            print("Followed ${posts[index].username}");
          },
          onSaveForLater: () async{
            // Call the savePostById function with the post's ID
           try {
            final success = await ref.read(homeViewModelProvider.notifier).toggleSaveForLater(posts[index].id);
            if (success) {
              // Optionally show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(posts[index].isSaved == true 
                      ? 'Post removed from saved items'
                      : 'Post saved for later'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
            print("Saved post: ${posts[index].id}");
          },
          // Replace the onReport and onNotInterested callbacks in your PostList's PostCard creation

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
                   await ref.read(homeViewModelProvider.notifier)
                    .reportPost(posts[index].id, selectedReason);
                
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
            
            print("Reported post: ${posts[index].id}");
          },

          onNotInterested: () {
          },
        );
      },
    );
  }
}

