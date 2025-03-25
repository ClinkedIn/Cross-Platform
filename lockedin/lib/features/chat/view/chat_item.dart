import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/view/chat_provider.dart';
import 'package:lockedin/features/chat/view/chats.dart';
import 'package:lockedin/features/chat/view/chat_history_screen.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

String formattedTime(DateTime timestamp) {
  final now = DateTime.now();

  if (timestamp.year == now.year &&
      timestamp.month == now.month &&
      timestamp.day == now.day) {
    // Same day -> Show time (e.g., "2:30 PM")
    return DateFormat('h:mm a').format(timestamp);
  } else if (timestamp.year == now.year) {
    // Same year -> Show month & day (e.g., "Mar 13")
    return DateFormat('MMM d').format(timestamp);
  } else {
    // Previous year -> Show month, day, and year (e.g., "Aug 16, 2023")
    return DateFormat('MMM d, y').format(timestamp);
  }
}

class ChatItem extends ConsumerWidget {
  final Chat chat;

  const ChatItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String formatted = formattedTime(chat.timestamp);

    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(chat.imageUrl)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            chat.name,
            style: AppTextStyles.headline2.copyWith(
              color:
                  ref.watch(themeProvider) == AppTheme.darkTheme
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          Text(
            formatted,
            style: AppTextStyles.bodyText2.copyWith(
              color:
                  ref.watch(themeProvider) == AppTheme.darkTheme
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyText1.copyWith(
                color:
                    ref.watch(themeProvider) == AppTheme.darkTheme
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ),
          if (chat.unreadCount > 0)
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue,
              child: Text(
                chat.unreadCount.toString(),
                style: AppTextStyles.bodyText1.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
      onTap: () {
        ref.read(chatProvider.notifier).markChatAsRead(chat);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailScreen(chat: chat)),
        );
      },
    );
  }
}
