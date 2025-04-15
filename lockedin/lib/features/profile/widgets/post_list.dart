import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home_page/model/post_model.dart';
import '../../home_page/viewModel/home_viewmodel.dart';
import 'post_card.dart';

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
                  await ref.read(homeViewModelProvider.notifier).toggleRepost(
                    posts[index].id,
                  );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
          onComment: () {
            print("Commented on post: ${posts[index].id}");
            print("number of comments: ${posts[index].comments}");
            context.push('/detailed-post/${posts[index].id}');
          },
          onShare: () async{
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
          onSaveForLater: () {
            // Call the savePostById function with the post's ID
            ref
                .read(homeViewModelProvider.notifier)
                .savePostById(posts[index].id);
            // Show a confirmation to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Post saved for later',
                  style: TextStyle(color: Colors.black87),
                ),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.white,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 200,
                  left: 10,
                  right: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            );
            print("Saved post: ${posts[index].id}");
          },
          onReport: () {
            // Add report functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post reported'),
                duration: Duration(seconds: 2),
              ),
            );
            print("Reported post: ${posts[index].id}");
          },
        );
      },
    );
  }
}
