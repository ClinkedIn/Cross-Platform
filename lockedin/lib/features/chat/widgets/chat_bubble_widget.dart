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
  final String senderImageUrl;
  final bool isRead;
  final String? attachmentUrl;
  final AttachmentType attachmentType;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.senderImageUrl,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType = AttachmentType.none,
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
              backgroundImage: NetworkImage(senderImageUrl),
              radius: 16,
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
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                attachmentUrl!,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, _) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
                loadingBuilder: (ctx, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
        
      case AttachmentType.document:
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
        
      case AttachmentType.gif:
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                attachmentUrl!,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, _) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Text("GIF")),
                ),
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