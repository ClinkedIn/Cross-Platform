import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/features/notifications/widgets/notifications_widgets.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

/// State provider to manage the currently selected notification category
final selectedCategoryProvider = StateProvider<String>((ref) => "All");
/// Notifications page UI
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    /// Watch the overall notifications provider (async state)
    final allNotifications = ref.watch(notificationsProvider);
    /// Currently selected notification category
    final selectedCategory = ref.watch(selectedCategoryProvider);
    /// Filter notifications based on selected category
    final notifications = allNotifications.when(
      data: (notificationsData) {
        switch (selectedCategory) {
          case 'Jobs':
            return notificationsData.isNotEmpty ? [notificationsData[0]] : [];
          case 'My posts':
            return notificationsData.length > 1 ? [notificationsData[1]] : [];
          case 'Mentions':
            return notificationsData.length > 2 ? [notificationsData[2]] : [];
          default:
            return notificationsData;
        }
      },
      loading: () => [],
      error: (_, __) => [],
    );  //will apply real filter later

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final selectedCategory = ref.watch(selectedCategoryProvider);
            ///// Render category filter buttons in the app bar
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildCategoryButton(
                  context,
                  ref,
                  "All",
                  selectedCategory == "All",
                ),
                SizedBox(width: 2.w),
                buildCategoryButton(
                  context,
                  ref,
                  "Jobs",
                  selectedCategory == "Jobs",
                ),
                SizedBox(width: 2.w),
                buildCategoryButton(
                  context,
                  ref,
                  "My posts",
                  selectedCategory == "My posts",
                ),
                SizedBox(width: 2.w),
                buildCategoryButton(
                  context,
                  ref,
                  "Mentions",
                  selectedCategory == "Mentions",
                ),
              ],
            );
          },
        ),
      ),
      body: allNotifications.when(
        data: (notificationsData) {
          if (notificationsData.isEmpty) {
            return Center(child: Text("No notifications available"));
          }
          /// Display list of notifications
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Slidable(
                key: ValueKey(notification.id), 
                /// Define actions when swiping from right to left
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.3,
                  children: [
                    /// Action to show less of this type of notification
                    CustomSlidableAction(
                      onPressed: (_) {
                        ref.read(notificationsProvider.notifier).showLessLikeThis(notification.id);
                      },
                      backgroundColor: Colors.grey[300]!,
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.zero, // remove internal padding
                      child: SizedBox.expand(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thumb_down_alt_outlined, color: Colors.black),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Show less',
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /// Action to delete the notification
                    CustomSlidableAction(
                      onPressed: (context) {
                        // Handle notification deletion
                        ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                        showDeleteMessage(context, () {
                          ref.read(notificationsProvider.notifier).undoDeleteNotification();
                        }, isDarkMode);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      child: SizedBox.expand(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Delete',
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ],
                ),
                /// When a notification is tapped
                child: GestureDetector(
                  onTap: () {
                    if (notification.isPlaceholder) return;
                    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                    ref.read(notificationsProvider.notifier).navigateToPost(context);
                  },
                  child: buildNotificationItem(notification, isDarkMode, ref, context),
                ),
              );
            },
          );
        }, 
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
      ),
    );
  }
}
