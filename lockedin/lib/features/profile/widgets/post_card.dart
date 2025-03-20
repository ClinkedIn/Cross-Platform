import 'package:flutter/material.dart';
import '../../home_page/model/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;

  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Makes it fill the screen width
      margin: EdgeInsets.symmetric(vertical: 8), // Keeps vertical spacing
      child: Card(
        margin: EdgeInsets.zero, // Ensures no extra margin
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Optional: Makes it edge-to-edge
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// **User Info Row (Profile + Name + Follow)**
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.profileImageUrl),
                    radius: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.username,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(width: 5),

                            /// **Follow Button**
                            TextButton(
                              onPressed: onFollow,
                              child: Text("• Follow", style: TextStyle(color: Colors.blue, fontSize: 14)),
                            ),
                          ],
                        ),
                        Text(
                          "${post.time} ${post.isEdited ? '· Edited' : ''}",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// **Post Content**
              SizedBox(height: 10),
              Text(post.content, style: TextStyle(fontSize: 14)),

              /// **Post Image (If Available)**
              if (post.imageUrl != null) ...[
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ],

              /// **Divider Line - Full Width**
              SizedBox(height: 10),
              Container(
                width: double.infinity, // Full width
                height: 1, // Defines thickness
                color: Colors.grey[300], // Light grey for subtle separation
              ),

              /// **Action Buttons (Like, Comment, Repost, Share) - Text Below Icons**
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Even spacing
                  children: [
                    /// **Like Button**
                    TextButton(
                      onPressed: onLike,
                      child: Column(
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, size: 20),
                          SizedBox(height: 2),
                          Text('Like', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),

                    /// **Comment Button**
                    TextButton(
                      onPressed: onComment,
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 20),
                          SizedBox(height: 2),
                          Text('Comment', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),

                    /// **Repost Button**
                    TextButton(
                      onPressed: () {
                        // Add functionality for reposting here
                      },
                      child: Column(
                        children: [
                          Icon(Icons.repeat, size: 20), // Repost icon
                          SizedBox(height: 2),
                          Text('Repost', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),

                    /// **Share Button**
                    TextButton(
                      onPressed: onShare,
                      child: Column(
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(height: 2),
                          Text('Share', style: TextStyle(fontSize: 12)),
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
}
