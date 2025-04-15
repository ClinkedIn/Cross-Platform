import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/view/chat_conversation_page.dart';
import 'package:lockedin/features/chat/viewModel/chat_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';

class ChatItem extends ConsumerWidget {
  final Chat chat;

  const ChatItem({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatViewModel = ref.read(chatProvider.notifier);
    
    return InkWell(
      onTap: () {
        // Mark as read when tapped
        if (chat.unreadCount > 0) {
          chatViewModel.markChatAsRead(chat);
        }
        
        // Navigate to chat conversation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(chat: chat),
          ),
        );
      },
      onLongPress: () {
        // Show the popup menu when long-pressed
        _showChatOptionsMenu(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundImage: chat.imageUrl.isNotEmpty
                  ? NetworkImage(chat.imageUrl)
                  : null,
              child: chat.imageUrl.isEmpty
                  ? Text(
                      chat.name.isNotEmpty ? chat.name[0].toUpperCase() : "?",
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),

            const SizedBox(width: 12),
            
            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chat name
                      Flexible(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Timestamp
                      Text(
                        _formatTimestamp(chat.timestamp),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Last message with sender name for group chats
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            children: [
                              // Show sender name for group chats
                              if (chat.chatType == 'group' && !chat.isSentByUser && chat.senderName.isNotEmpty)
                                TextSpan(
                                  text: "${chat.senderName}: ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              // Show 'You: ' prefix for messages sent by the user
                              if (chat.isSentByUser)
                                const TextSpan(
                                  text: "You: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              TextSpan(text: chat.lastMessage),
                            ],
                          ),
                        ),
                      ),
                      
                      // Unread count badge
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show the popup menu with chat options
  void _showChatOptionsMenu(BuildContext context, WidgetRef ref) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'mark_unread',
          child: Row(
            children: [
              Icon(Icons.mark_email_unread, color: Colors.blue),
              SizedBox(width: 8),
              Text('Mark as unread'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'mark_unread') {
        // Call the viewModel method to mark as unread
        ref.read(chatProvider.notifier).markChatAsUnread(chat);
        
        // Show a confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${chat.name} marked as unread'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
  
  // Format timestamp to a user-friendly string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Today: show time
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      // This week: show day name
      return DateFormat('EEEE').format(timestamp);
    } else {
      // Older: show date
      return DateFormat('MM/dd/yy').format(timestamp);
    }
  }
}