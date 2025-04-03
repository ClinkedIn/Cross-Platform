import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:sizer/sizer.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsViewModel, List<NotificationModel>>(
      (ref) => NotificationsViewModel(),
    );

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final navBarTheme = theme.bottomNavigationBarTheme;
    final unseenNotifications =
        ref.watch(notificationsProvider).where((notification) => !notification.isSeen).length;

    return Container(
      color: navBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.home, 'Home', onTap: () => onTap(0)),
            _buildNavItem(context, 1, Icons.group, 'My Network', onTap: () => onTap(1)),
            _buildNavItem(context, 2, Icons.add_box_outlined, 'Post', onTap: () => onTap(2)),
            _buildNavItem(
              context,
              3,
              Icons.notifications,
              'Notifications',
              unseenNotificationsCount: unseenNotifications,
              onTap: () {
                // Mark all notifications as read when the user taps on Notifications
                ref.read(notificationsProvider.notifier).markAllAsSeen();
                onTap(3); // Navigate to the Notifications page
              }
            ),
            _buildNavItem(context, 4, Icons.work, 'Jobs', onTap: () => onTap(4)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label, {
    int? unseenNotificationsCount,
    VoidCallback? onTap,
  }) {
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
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: iconColor, size: iconSize),
                  if (index == 3 &&
                      unseenNotificationsCount != null &&
                      unseenNotificationsCount >
                          0) // Only add badge for Notifications tab
                    Positioned(
                      top: -5,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unseenNotificationsCount.toString(), // Replace with dynamic value if needed
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
