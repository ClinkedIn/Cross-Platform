import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: AppTextStyles.headline1.copyWith(
            color:
                ref.watch(themeProvider) == AppTheme.darkTheme
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading state
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return GestureDetector(
                  onTap: () =>
                    ref.read(notificationsProvider.notifier).markAsReadAndNavigate(context, index),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.transparent : Colors.blue[50], // ✅ Baby blue for unread
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5.w,
                        )
                      ),
                    ),
                  
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 2.w),
                        // Profile Picture
                        CircleAvatar(
                          backgroundImage: NetworkImage(notification.profileImageUrl),
                          radius: 24,
                        ),

                        SizedBox(width: 2.w),

                        // Notification Text (Username + Activity + Description)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.headline2.copyWith(
                                    color: ref.watch(themeProvider) == AppTheme.darkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "${notification.username} ",
                                      style: AppTextStyles.bodyText1.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${notification.activityType} ",
                                      style: AppTextStyles.bodyText1
                                    ),
                                    TextSpan(
                                      text: notification.description,
                                      style: AppTextStyles.bodyText1
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 2.w),

                        // Time Ago + More Options Button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              notification.timeAgo,
                              style: AppTextStyles.bodyText1.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Icon(Icons.more_vert, size: 2.h, color: Colors.black),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
