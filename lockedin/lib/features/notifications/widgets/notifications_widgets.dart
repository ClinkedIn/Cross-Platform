import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/view/notifications_page.dart';
import 'package:lockedin/features/notifications/state/notification_settings_provider.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

Widget buildCategoryButton( BuildContext context, WidgetRef ref, String label, bool isSelected) {
  final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
  return OutlinedButton(
    style: AppButtonStyles.outlinedButton.copyWith(
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      ),
      backgroundColor: WidgetStateProperty.all(
        isSelected
            ? Colors.green[700]
            : isDarkMode
            ? Colors.black
            : Colors.white,
      ),
      side: WidgetStateProperty.all(
        BorderSide(
          color: isDarkMode ? Colors.white : Colors.grey[600]!,
          width: 0.3.w,
        ),
      ),
    ),
    onPressed: () {
      ref.read(selectedCategoryProvider.notifier).state = label;
    },
    child: Text(
      label,
      style: AppTextStyles.bodyText1.copyWith(
        color: isDarkMode || isSelected ? Colors.white : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}

Widget buildBottomSheet(BuildContext context, bool isDarkMode, String username) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.notifications, color: isDarkMode ? Colors.white : Colors.black),
          title: Text("Change notification preferences", style: AppTextStyles.bodyText1.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          )),
          onTap: () {
            // Handle notification preferences
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              builder: (context) => buildNotificationPreferencesSheet(context, isDarkMode, username)
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text("Delete notification", style: AppTextStyles.bodyText1.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          )),
          onTap: () {
            // Handle notification deletion
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.thumb_down, color: isDarkMode ? Colors.white : Colors.black),
          title: Text("Show less like this", style: AppTextStyles.bodyText1.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          )),
          onTap: () {
            // Handle "Show less like this"
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

Widget buildNotificationPreferencesSheet(BuildContext context, bool isDarkMode, String username) {
  return Consumer(
    builder: (context, ref, _) {
      final settings = ref.watch(notificationSettingsProvider)[username] ??
          NotificationSettings(allowUserNotifications: true, allowNetworkUpdates: true);

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Allow notifications about",
                  style: AppTextStyles.bodyText1.copyWith(fontSize: 2.h, 
                  color: isDarkMode ? Colors.white : Colors.black),
                ),
                ListTile(
                  title: Text(username, style: AppTextStyles.bodyText1.copyWith(
                    color: isDarkMode ? Colors.white : Colors.grey[700]),
                  ),
                  trailing: Switch(
                    value: settings.allowUserNotifications,
                    onChanged: (value) {
                      ref.read(notificationSettingsProvider.notifier).toggleUserNotifications(username, value);
                      showToggleMessage(context,
                      value ? "You turned on notifications about $username. For more options, go to $username's profile." :
                              "You'll no longer receive notifications about $username. For more options, go to $username's profile.", isDarkMode);
                    },
                    activeColor: Colors.green[900],
                    activeTrackColor: Colors.green[600],
                    inactiveTrackColor: Colors.grey[500],
                    inactiveThumbColor: Colors.grey[700],
                  ),
                ),
                ListTile(
                  title: Text("Updates from your network", style: AppTextStyles.bodyText1.copyWith(
                    color: isDarkMode ? Colors.white : Colors.grey[700],),
                  ),
                  trailing: Switch(
                    value: settings.allowNetworkUpdates,
                    onChanged: (value) {
                      ref.read(notificationSettingsProvider.notifier).toggleNetworkUpdates(username, value);
                      showToggleMessage(context,
                      value ? 'You turned on notifications about updates from your network. For more options, go to "connecting with others" in Notification settings.' :
                              'You\'ll no longer receive notifications about updates from your network. For more options, go to "connecting with others" in Notification settings.', isDarkMode);
                    },
                    activeColor: Colors.green[900],
                    activeTrackColor: Colors.green[600],
                    inactiveTrackColor: Colors.grey[500],
                    inactiveThumbColor: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ),
          );
        },
      );
    },
  );
}

void showToggleMessage(BuildContext context, String message, bool isDarkMode) {
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).size.height * 0.22, // Adjust position
      left: MediaQuery.of(context).size.width * 0.02,
      right: MediaQuery.of(context).size.width * 0.02,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyText1.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 6.w,
                ),
                onPressed: () {
                  overlayEntry.remove();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  // Remove the overlay after 2 seconds
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

