import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_post_model.dart';

class PostCard extends StatelessWidget {
  final CompanyPost post;
  final String? companyLogoUrl;
  final File? pickedImage;

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
      avatarImage = FileImage(pickedImage!);
    } else if (post.companyLogoUrl.isNotEmpty) {
      avatarImage = NetworkImage(
        post.companyLogoUrl.startsWith('http')
            ? post.companyLogoUrl
            : 'https://lockedin-cufe.me/api${post.companyLogoUrl}',
      );
    } else {
      avatarImage = const AssetImage('assets/images/default_profile_photo.png');
    }

    debugPrint('🟨 Building PostCard for post: ${post.id}');
    debugPrint('📝 Description: "${post.description}"');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: avatarImage, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Description with debug container
          if (post.description.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                color: Colors.yellow.withOpacity(0.2), // Highlight container
                child: Text(
                  '📝 ${post.description}',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '⚠️ No description provided for post "${post.id}"',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),

          // Attachments
          if (post.attachments.isNotEmpty)
            ...post.attachments.map(
              (url) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url.startsWith('http')
                        ? url
                        : 'https://lockedin-cufe.me/api/$url',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Reactions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 20),
                const SizedBox(width: 4),
                Text('${post.impressionCounts["total"] ?? 0}'),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text('${post.commentCount}'),
                const SizedBox(width: 16),
                const Icon(Icons.repeat, size: 20),
                const SizedBox(width: 4),
                Text('${post.repostCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    debugPrint('🟦 Time formatting for: ${post.description}');

    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
