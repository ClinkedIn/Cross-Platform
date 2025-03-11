import 'package:flutter/material.dart';
import '../../home_page/model/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.username, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(post.content),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${post.likes} Likes'),
                Text('${post.comments} Comments'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
