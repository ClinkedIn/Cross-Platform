import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String imageUrl;
  final bool isOnline;
  final bool isDarkMode;

  const ChatAppBar({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 30,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.headline2.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: AppTextStyles.bodyText2.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Add chat options
          },
        ),
      ],
    );
  }
}
