import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

class UpperNavbar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget leftIcon;
  final VoidCallback leftOnPress;

  const UpperNavbar({
    super.key,
    required this.leftIcon,
    required this.leftOnPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme == AppTheme.darkTheme;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(icon: leftIcon, onPressed: leftOnPress),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.grey[200],
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          ),
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
      actions: [
        // Theme Toggle Button
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Colors.grey[700]),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
