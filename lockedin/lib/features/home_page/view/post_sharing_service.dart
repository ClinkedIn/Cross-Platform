import 'dart:math';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class PostSharingService {
  // Generate a shareable link for a post
  static String generatePostLink(String postId) {
    // Replace this with your actual domain
    return 'http://link-up-mobile/detailed-post/$postId';
  }

  static Future<void> sharePost({
    required String postId,
    required String postContent,
    required BuildContext context,
  }) async {
    final String postLink = generatePostLink(postId);
    final String shareText = '${postContent.length > 50 ? '${postContent.substring(0, 50)}...' : postContent}\n\nCheck out this post: $postLink';
    
    try {
      // More reliable sharing approach
      await Share.share(
        shareText,
        subject: 'Check out this post on LockedIn',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1), // Provide a default position on iOS
      ).catchError((e) {
        debugPrint('Share.share error: $e');
        throw e; // Rethrow to be caught by the outer catch
      });
    } catch (e) {
      debugPrint('Error sharing post: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share post: ${e.toString().substring(0, min(e.toString().length, 50))}')),
        );
      }
    }
  }

  // Copy post link to clipboard
  static Future<void> copyPostLink({
    required String postId,
    required BuildContext context,
  }) async {
    final String postLink = generatePostLink(postId);
    
    try {
      await Clipboard.setData(ClipboardData(text: postLink));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      }
    } catch (e) {
      debugPrint('Error copying link: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to copy link')),
        );
      }
    }
  }

  // Show sharing options bottom sheet
  static void showSharingOptions({
    required BuildContext context,
    required String postId,
    required String postContent,
    required VoidCallback onRepost,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Share Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Repost within LockedIn'),
            onTap: () {
              Navigator.pop(context);
              onRepost();
            },
          ),
          ListTile(
            leading: Icon(Icons.adaptive.share),
            title: const Text('Share to other apps'),
            onTap: () {
              Navigator.pop(context);
              sharePost(
                postId: postId,
                postContent: postContent,
                context: context,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy link'),
            onTap: () {
              Navigator.pop(context);
              copyPostLink(
                postId: postId,
                context: context,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}