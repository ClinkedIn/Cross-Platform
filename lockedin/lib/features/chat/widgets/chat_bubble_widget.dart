import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class ChatBubble extends ConsumerWidget {
  final String message;
  final bool isMe;
  final String time;
  final String? senderImageUrl;
  final bool isRead;
  final String? attachmentUrl;
  final AttachmentType attachmentType;
  final String? receiverId; // Add receiverId to check against readBy

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    this.senderImageUrl,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType = AttachmentType.none,
    this.receiverId, // Add receiverId parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: senderImageUrl != null && senderImageUrl!.isNotEmpty
                  ? NetworkImage(senderImageUrl!)
                  : null,
              radius: 16,
              child: senderImageUrl == null || senderImageUrl!.isEmpty
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe 
                ? AppColors.primary 
                : isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display attachment if present
                if (attachmentType != AttachmentType.none && attachmentUrl != null)
                  _buildAttachmentWidget(context),
                  
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : (isDarkMode ? Colors.white : Colors.black87),
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.done_all,
              size: 16,
              color: isRead ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAttachmentWidget(BuildContext context) {
    
    switch (attachmentType) {
      case AttachmentType.image:
        if (attachmentUrl == null || attachmentUrl!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Clean the URL from brackets if they exist
        String cleanUrl = attachmentUrl!;
        if (cleanUrl.startsWith('[') && cleanUrl.endsWith(']')) {
          cleanUrl = cleanUrl.substring(1, cleanUrl.length - 1);
        }
        
        // Validate URL before passing to Image.network
        bool isValidUrl = false;
        try {
          final uri = Uri.parse(cleanUrl);
          isValidUrl = uri.hasScheme && uri.scheme.startsWith(RegExp(r'[a-zA-Z]'));
        } catch (e) {
          debugPrint('Invalid URL format: $e');
        }
        
        if (!isValidUrl) {
          // Show placeholder for invalid URLs
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_not_supported, size: 40),
                    SizedBox(height: 8),
                    Text('Invalid image URL format', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 150,
                child: Image.network(
                  cleanUrl,  // Use the cleaned URL here
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, _) {
                    debugPrint('Error loading image: $error');
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported, size: 40),
                          const SizedBox(height: 8),
                          Text('Failed to load image: ${error.toString().substring(0, min(30, error.toString().length))}...', 
                               style: const TextStyle(fontSize: 12))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
        
      case AttachmentType.document:
        // Document handler remains the same
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Document",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
       
      default:
        return const SizedBox.shrink();
    }
  }
}