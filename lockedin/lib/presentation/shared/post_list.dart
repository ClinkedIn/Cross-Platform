import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'post_card.dart';

class PostList extends StatelessWidget {
  final List<PostModel> posts;

  const PostList({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: posts[index]);
      },
    );
  }
}
