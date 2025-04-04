import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/view/chat_item.dart';
import 'package:lockedin/features/chat/view/chat_provider.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatProvider);

    final sortedChats =
        chats.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats",
          style: AppTextStyles.headline1.copyWith(
            color:
                ref.watch(themeProvider) == AppTheme.darkTheme
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
      body:
          chats.isEmpty
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loader while fetching
              : ListView.builder(
                itemCount: sortedChats.length,
                itemBuilder:
                    (context, index) => ChatItem(chat: sortedChats[index]),
              ),
    );
  }
}
