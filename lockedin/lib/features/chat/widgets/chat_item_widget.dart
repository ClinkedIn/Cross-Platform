import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/core/utils/date_utils.dart' as custom_date_utils;


class ChatItem extends ConsumerWidget {
  final Chat chat;
  final Function(BuildContext, Chat) onTap;
  final Function(BuildContext, Chat) onLongPress;

  const ChatItem({
    Key? key, 
    required this.chat,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return InkWell(
      onTap: () => onTap(context, chat),
      onLongPress: () => onLongPress(context, chat),
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
            _buildAvatar(),
            const SizedBox(width: 12),
            
            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChatHeader(context),
                  const SizedBox(height: 4),
                  _buildChatPreview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvatar() {
    return CircleAvatar(
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
    );
  }
  
  Widget _buildChatHeader(BuildContext context) {
    return Row(
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
        
        // Timestamp using DateUtils
        Text(
          custom_date_utils.DateUtils.timeAgo(chat.timestamp),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: chat.unreadCount > 0
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildChatPreview() {
    return Row(
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
    );
  }
}