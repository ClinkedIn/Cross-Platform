import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          onLike: () {
            print("Liked post: ${posts[index].id}");
          },
          onComment: () {
            print("Commented on post: ${posts[index].id}");
          },
          onShare: () {
            print("Shared post: ${posts[index].id}");
          },
          onFollow: () {
            print("Followed ${posts[index].username}");
          },
          onSaveForLater: () {
            // Call the savePostById function with the post's ID
            ref.read(homeViewModelProvider.notifier).savePostById(posts[index].id);
            
            // Show a confirmation to the user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post saved for later'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
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