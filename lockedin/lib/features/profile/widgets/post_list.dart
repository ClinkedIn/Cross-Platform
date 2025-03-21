import 'package:flutter/material.dart';
import '../../home_page/model/post_model.dart';
import 'post_card.dart';

class PostList extends StatelessWidget {
  final List<PostModel> posts;

  const PostList({required this.posts, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        );
      },
    );
  }
}

