import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String? companyLogoUrl;
  final File? pickedImage; // <-- Add picked image as a File

  const PostCard({
    super.key,
    required this.post,
    this.companyLogoUrl,
    this.pickedImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;

    if (pickedImage != null) {
      avatarImage = FileImage(pickedImage!); // Local picked image
    } else if (companyLogoUrl != null && companyLogoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(
        companyLogoUrl!.startsWith('http')
            ? companyLogoUrl!
            : 'http://10.0.2.2:3000/$companyLogoUrl',
      );
    } else {
      avatarImage = const AssetImage('assets/company_logo.png');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: avatarImage),
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
                const Icon(Icons.thumb_up_alt_outlined, size: 20),
                const SizedBox(width: 4),
                Text(post.likes.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text(post.comments.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.repeat, size: 20),
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
