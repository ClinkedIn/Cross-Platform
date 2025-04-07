import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget leftIcon;
  final VoidCallback leftOnPress;

  const CustomAppbar({
    super.key,
    required this.leftIcon,
    required this.leftOnPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme == AppTheme.darkTheme;

    return AppBar(
        title: Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: isDarkMode ?  Colors.black : theme.primaryColor,
        actions: [
          IconButton(
            onPressed: leftOnPress,
            icon: Icon(Icons.close, color: Colors.white, size: 30),
            highlightColor: const Color.fromARGB(94, 255, 255, 255),
          ),
        ],
      );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
