import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/features/chat/widgets/block_button_widget.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String imageUrl;
  final bool isDarkMode;
  final String chatId;
  final List<Widget>? additionalActions;

  const ChatAppBar({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.isDarkMode,
    required this.chatId,
    this.additionalActions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => context.pop(), // Navigate back to chat list
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: imageUrl.isNotEmpty 
                ? NetworkImage(imageUrl) as ImageProvider
                : AssetImage('assets/images/default_avatar.png'),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.headline2.copyWith(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Add the block button widget
        BlockButtonWidget(chatId: chatId),
        // Include any additional actions if provided
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }
}
