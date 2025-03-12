import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBarTheme = theme.bottomNavigationBarTheme;

    return Container(
      color: navBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.home, 'Home'),
            _buildNavItem(context, 1, Icons.group, 'My Network'),
            _buildNavItem(context, 2, Icons.add_box_outlined, 'Post'),
            _buildNavItem(context, 3, Icons.notifications, 'Notifications'),
            _buildNavItem(context, 4, Icons.work, 'Jobs'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final navBarTheme = theme.bottomNavigationBarTheme;
    final bool isSelected = currentIndex == index;

    final iconColor =
        isSelected
            ? navBarTheme.selectedItemColor
            : navBarTheme.unselectedItemColor;

    final indicatorColor = navBarTheme.selectedItemColor;

    final iconSize =
        isSelected
            ? navBarTheme.selectedIconTheme?.size ?? 28
            : navBarTheme.unselectedIconTheme?.size ?? 28;

    final textStyle =
        isSelected
            ? navBarTheme.selectedLabelStyle
            : navBarTheme.unselectedLabelStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selection indicator line
        Container(
          height: 2,
          width: 30,
          color: isSelected ? indicatorColor : Colors.transparent,
          margin: const EdgeInsets.only(bottom: 5),
        ),
        InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: iconSize),
              const SizedBox(height: 4),
              Text(label, style: textStyle),
            ],
          ),
        ),
      ],
    );
  }
}

final navProvider = StateNotifierProvider<NavViewModel, int>(
  (ref) => NavViewModel(),
);

class NavViewModel extends StateNotifier<int> {
  NavViewModel() : super(0); // Default to Home Tab

  void changeTab(int index) {
    state = index;
  }
}
