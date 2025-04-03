import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/features/notifications/widgets/notifications_widgets.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => "All");

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final allNotifications = ref.watch(notificationsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final notifications =
        selectedCategory == "All"
            ? allNotifications
            : selectedCategory == "Jobs"
            ? allNotifications
                .where((notification) => (notification.id + 2) % 3 == 0)
                .toList()
            : selectedCategory == "My posts"
            ? allNotifications
                .where((notification) => (notification.id + 1) % 3 == 0)
                .toList()
            : allNotifications
                .where((notification) => notification.id % 3 == 0)
                .toList(); //will apply real filter later

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final selectedCategory = ref.watch(selectedCategoryProvider);

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
      body:
          allNotifications.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading state
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return GestureDetector(
                    onTap: () {
                      final originalIndex = allNotifications.indexOf(
                        notification,
                      );
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsReadAndNavigate(context, originalIndex);
                    },
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
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 0.5.w,
                          ),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 2.w),
                          // Profile Picture
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              notification.profileImageUrl,
                            ),
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
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${notification.username} ",
                                        style: AppTextStyles.bodyText1.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${notification.activityType} ",
                                        style: AppTextStyles.bodyText1.copyWith(
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      if (notification.secondUsername.isNotEmpty)
                                        TextSpan(
                                          text: "${notification.secondUsername} ",
                                          style: AppTextStyles.bodyText1.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                      TextSpan(
                                        text: notification.description,
                                        style: AppTextStyles.bodyText1.copyWith(
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
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
                                    builder: (context) => buildBottomSheet(context, isDarkMode, notification.username),
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
                },
              ),
    );
  }
}