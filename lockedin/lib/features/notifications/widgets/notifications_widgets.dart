import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'package:lockedin/features/notifications/view/notifications_page.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/features/notifications/state/notification_settings_provider.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

/// This widget is used to build the notification item in the notifications page.
/// When swiped left it shows 'Show less' and 'Delete' buttons.
/// Applies a different background if the notification is unread.
Widget buildNotificationItem(
  NotificationModel notification,
  bool isDarkMode,
  WidgetRef ref,
  BuildContext context,
) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? Colors.transparent
                : isDarkMode
                ? Colors.grey[500]!
                : Colors.blue[50], // ✅ Baby blue for unread
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5.w),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 2.w),
          // Profile Picture
          if (!notification.isPlaceholder)
            CircleAvatar(
              backgroundImage:
                  notification.sendingUser.profilePicture != null
                      ? NetworkImage(notification.sendingUser.profilePicture!)
                      : AssetImage('assets/images/default_profile_photo.png')
                          as ImageProvider,
              radius: 24,
            ),

          !notification.isPlaceholder
              ? SizedBox(width: 2.w)
              : SizedBox(width: 5.w),

          // Notification Text (Username + Activity + Description)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.headline2.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    children: [
                      if (!notification.isPlaceholder)
                        TextSpan(
                          text:
                              "${notification.content.split(" ").take(2).join(" ")} ",
                          style: AppTextStyles.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      if (!notification.isPlaceholder)
                        TextSpan(
                          text: notification.content
                              .split(" ")
                              .skip(2)
                              .join(" "),
                          style: AppTextStyles.bodyText1.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      // if (!notification.isPlaceholder &&
                      //     notification.secondUsername.isNotEmpty)
                      //   TextSpan(
                      //     text: "${notification.secondUsername} ",
                      //     style: AppTextStyles.bodyText1.copyWith(
                      //       fontWeight: FontWeight.bold,
                      //       color: isDarkMode ? Colors.white : Colors.black,
                      //     ),
                      //   ),
                      if (notification.isPlaceholder)
                        TextSpan(
                          text:
                              "Thanks. Your feedback helps us improve your notifications. ",
                          style: AppTextStyles.bodyText1.copyWith(
                            color: Colors.green[800],
                          ),
                        ),
                      if (notification.isPlaceholder)
                        TextSpan(
                          text: "Undo",
                          style: AppTextStyles.bodyText1.copyWith(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  ref
                                      .read(notificationsProvider.notifier)
                                      .undoShowLessLikeThis(notification.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                  }
                                },
                        ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 2.w),

          // Time Ago + More Options Button
          if (!notification.isPlaceholder)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  notification.timeAgo,
                  style: AppTextStyles.bodyText1.copyWith(
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 3.h,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (context) => buildBottomSheet(
                            context,
                            ref,
                            isDarkMode,
                            "${notification.sendingUser.firstName} ${notification.sendingUser.lastName}",
                            notification.id,
                          ),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

/// This widget is used to build the category buttons in the filter section of the notifications page.
/// Categories include 'All', 'Jobs', 'My posts', and 'Mentions'.
/// The selected category is highlighted with a different color.
Widget buildCategoryButton(
  BuildContext context,
  WidgetRef ref,
  String label,
  bool isSelected,
) {
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

/// This widget is used to build the bottom sheet that appears when the user clicks on the more options button in a notification.
/// It contains options to change notification preferences, delete the notification, and show less like this.
/// The options are displayed as list tiles with icons.
Widget buildBottomSheet(
  BuildContext context,
  WidgetRef ref,
  bool isDarkMode,
  String username,
  String id,
) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            Icons.notifications,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          title: Text(
            "Change notification preferences",
            style: AppTextStyles.bodyText1.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {
            // Handle notification preferences
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              builder:
                  (context) => buildNotificationPreferencesSheet(
                    context,
                    isDarkMode,
                    username,
                  ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text(
            "Delete notification",
            style: AppTextStyles.bodyText1.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {
            // Handle notification deletion
            ref.read(notificationsProvider.notifier).deleteNotification(id);
            showDeleteMessage(context, () {
              ref.read(notificationsProvider.notifier).undoDeleteNotification();
            }, isDarkMode);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.thumb_down,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          title: Text(
            "Show less like this",
            style: AppTextStyles.bodyText1.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {
            // Handle "Show less like this"
            ref.read(notificationsProvider.notifier).showLessLikeThis(id);
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

/// This widget is used to build the notification preferences bottom sheet that appears when the user clicks on the change notification preferences option in a notification.
/// It contains options to allow or disallow notifications about the user and updates from the network.
/// The options are displayed as list tiles with switches.
Widget buildNotificationPreferencesSheet(
  BuildContext context,
  bool isDarkMode,
  String username,
) {
  return Consumer(
    builder: (context, ref, _) {
      final settings =
          ref.watch(notificationSettingsProvider)[username] ??
          NotificationSettings(
            allowUserNotifications: true,
            allowNetworkUpdates: true,
          );

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Allow notifications about",
                  style: AppTextStyles.bodyText1.copyWith(
                    fontSize: 2.h,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                ListTile(
                  title: Text(
                    username,
                    style: AppTextStyles.bodyText1.copyWith(
                      color: isDarkMode ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  trailing: Switch(
                    value: settings.allowUserNotifications,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .toggleUserNotifications(username, value);
                      showToggleMessage(
                        context,
                        value
                            ? "You turned on notifications about $username. For more options, go to $username's profile."
                            : "You'll no longer receive notifications about $username. For more options, go to $username's profile.",
                        isDarkMode,
                      );
                    },
                    activeColor: Colors.green[900],
                    activeTrackColor: Colors.green[600],
                    inactiveTrackColor: Colors.grey[500],
                    inactiveThumbColor: Colors.grey[700],
                  ),
                ),
                ListTile(
                  title: Text(
                    "Updates from your network",
                    style: AppTextStyles.bodyText1.copyWith(
                      color: isDarkMode ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  trailing: Switch(
                    value: settings.allowNetworkUpdates,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .toggleNetworkUpdates(username, value);
                      showToggleMessage(
                        context,
                        value
                            ? 'You turned on notifications about updates from your network. For more options, go to "connecting with others" in Notification settings.'
                            : 'You\'ll no longer receive notifications about updates from your network. For more options, go to "connecting with others" in Notification settings.',
                        isDarkMode,
                      );
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

/// This function shows a temporary overlay message when the user toggles notification settings.
/// The message indicates whether the notifications are turned on or off.
/// It disappears after 2 seconds or when the close button is pressed.
void showToggleMessage(BuildContext context, String message, bool isDarkMode) {
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
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
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

/// This function shows a temporary overlay message when the user deletes a notification.
/// The message indicates that the notification has been deleted and provides an option to undo the action.
/// It disappears after 3 seconds or when the close button is pressed.
void showDeleteMessage(
  BuildContext context,
  VoidCallback onUndo,
  bool isDarkMode,
) {
  if (!context.mounted) return; // Prevent accessing a deactivated widget
  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          Icons.delete,
          color: isDarkMode ? Colors.white : Colors.black,
        ), // Trash icon on the left
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Notification deleted.',
            style: AppTextStyles.bodyText1.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            onUndo();
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }
          },
          child: Text(
            'Undo',
            style: AppTextStyles.bodyText1.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
    action: SnackBarAction(
      label: '✖',
      textColor: isDarkMode ? Colors.white : Colors.black,
      onPressed: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      },
    ),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating, // Makes it float like in the image
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ), // Smooth rounded edges
    backgroundColor:
        isDarkMode
            ? Colors.grey[800]
            : Colors.white, // Background color similar to the image
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
