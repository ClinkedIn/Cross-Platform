import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
// Import url_launcher for opening URLs
import 'package:url_launcher/url_launcher.dart';
// Import a photo viewer package for image viewing
import 'package:photo_view/photo_view.dart';

class ChatBubble extends ConsumerWidget {
  final String message;
  final bool isMe;
  final String time;
  final String? senderImageUrl;
  final bool isRead;
  final String? attachmentUrl;
  final AttachmentType attachmentType;
  final String? receiverId;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    this.senderImageUrl,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType = AttachmentType.none,
    this.receiverId,
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
            GestureDetector(
              onTap: () => _openImageFullScreen(context, cleanUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        cleanUrl,
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
                      
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
        
      case AttachmentType.document:
        return Column(
          children: [
            GestureDetector(
              onTap: () => _openDocument(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Document",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Tap to open",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ],
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

  // Method to open image in full screen
  void _openImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  // Method to open document
  void _openDocument(BuildContext context) async {
    if (attachmentUrl == null || attachmentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open document: URL is missing')),
      );
      return;
    }
    
    // Clean the URL from brackets if they exist
    String cleanUrl = attachmentUrl!;
    if (cleanUrl.startsWith('[') && cleanUrl.endsWith(']')) {
      cleanUrl = cleanUrl.substring(1, cleanUrl.length - 1);
    }
    
    try {
      final Uri url = Uri.parse(cleanUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open document')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening document: ${e.toString()}')),
      );
    }
  }
}