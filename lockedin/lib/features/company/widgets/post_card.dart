import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage(
                'assets/company_logo.png',
              ), // Placeholder
            ),
            title: Text(post.title),
            subtitle: Text(post.timeAgo),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(post.imageUrl, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 20),
                const SizedBox(width: 4),
                Text(post.likes.toString()),
                const SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text(post.comments.toString()),
                const SizedBox(width: 16),
                Icon(Icons.repeat, size: 20),
                const SizedBox(width: 4),
                Text(post.reposts.toString()),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
