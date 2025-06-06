import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/features/notifications/widgets/notifications_widgets.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

/// State provider to manage the currently selected notification category
final selectedCategoryProvider = StateProvider<String>((ref) => "All");

/// Notifications page UI
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => NotificationsPageState();
}

class NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Re-fetch notifications when page is built
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;

    /// Watch the overall notifications provider (async state)
    final allNotifications = ref.watch(notificationsProvider);

    /// Currently selected notification category
    final selectedCategory = ref.watch(selectedCategoryProvider);

    /// Filter notifications based on selected category
    final List<NotificationModel> notifications = allNotifications.when(
      data: (notificationsData) {
        switch (selectedCategory) {
          case 'Jobs':
            return notificationsData.where((n) => n.subject == 'job').toList();
          case 'impression':
            return notificationsData
                .where((n) => n.subject == 'impression')
                .toList();
          case 'connection request':
            return notificationsData
                .where((n) => n.subject == 'connection request')
                .toList();
          case 'message':
            return notificationsData
                .where((n) => n.subject == 'message')
                .toList();
          case 'follow':
            return notificationsData
                .where((n) => n.subject == 'follow')
                .toList();
          case 'post':
            return notificationsData.where((n) => n.subject == 'post').toList();
          default:
            return notificationsData;
        }
      },
      loading: () => [],
      error: (_, __) => [],
    ); //will apply real filter later

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final selectedCategory = ref.watch(selectedCategoryProvider);
            ///// Render category filter buttons in the app bar
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildCategoryButton(
                      context,
                      ref,
                      "All",
                      selectedCategory == "All",
                    ),
                    SizedBox(width: 8),
                    buildCategoryButton(
                      context,
                      ref,
                      "Jobs",
                      selectedCategory == "Jobs",
                    ),
                    SizedBox(width: 8),
                    buildCategoryButton(
                      context,
                      ref,
                      "impression",
                      selectedCategory == "impression",
                    ),
                    SizedBox(width: 8),
                    buildCategoryButton(
                      context,
                      ref,
                      "connection request",
                      selectedCategory == "connection request",
                    ),
                    SizedBox(width: 8),
                    buildCategoryButton(
                      context,
                      ref,
                      "message",
                      selectedCategory == "message",
                    ),
                    SizedBox(width: 8),
                    buildCategoryButton(
                      context,
                      ref,
                      "follow",
                      selectedCategory == "follow",
                    ),
                    SizedBox(width: 8),
                    buildCategoryButton(
                      context,
                      ref,
                      "post",
                      selectedCategory == "post",
                    ),
                    // Add a bit of padding at the end for better scrolling experience
                    SizedBox(width: 8),
                  ],
                ),
              ),
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
                        ref
                            .read(notificationsProvider.notifier)
                            .showLessLikeThis(notification.id);
                      },
                      backgroundColor: Colors.grey[300]!,
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.zero, // remove internal padding
                      child: SizedBox.expand(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_down_alt_outlined,
                              color: Colors.black,
                            ),
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
                        ref
                            .read(notificationsProvider.notifier)
                            .deleteNotification(notification.id);
                        showDeleteMessage(context, () {
                          ref
                              .read(notificationsProvider.notifier)
                              .undoDeleteNotification();
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
                      ),
                    ),
                  ],
                ),

                /// When a notification is tapped
                child: GestureDetector(
                  onTap: () {
                    if (notification.isPlaceholder) return;

                    ref
                        .read(notificationsProvider.notifier)
                        .markAsRead(notification.id);
                    ref
                        .read(notificationsProvider.notifier)
                        .navigateToPost(
                          context,
                          notification.relatedPostId,
                          notification,
                        );
                  },
                  child: buildNotificationItem(
                    notification,
                    isDarkMode,
                    ref,
                    context,
                  ),
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
