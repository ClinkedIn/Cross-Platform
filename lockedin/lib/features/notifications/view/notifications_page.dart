import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/features/notifications/view/jobs.dart';
import 'package:lockedin/features/notifications/view/myPosts.dart';
import 'package:lockedin/features/notifications/view/mentions.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:sizer/sizer.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => "All");

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final selectedCategory = ref.watch(selectedCategoryProvider);
        
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildCategoryButton(context, ref, "All", selectedCategory == "All", null),
                SizedBox(width: 2.w),
                buildCategoryButton(context, ref, "Jobs", selectedCategory == "Jobs", JobsPage()),
                SizedBox(width: 2.w),
                buildCategoryButton(context, ref, "My posts", selectedCategory == "My posts", MyPostsPage()),
                SizedBox(width: 2.w),
                buildCategoryButton(context, ref, "Mentions", selectedCategory == "Mentions", MentionsPage()),
              ],
            );
          },
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
                      color: notification.isRead ? Colors.transparent : isDarkMode ? Colors.grey[500]! : Colors.blue[50], // ✅ Baby blue for unread
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
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "${notification.username} ",
                                      style: AppTextStyles.bodyText1.copyWith(
                                        fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${notification.activityType} ",
                                      style: AppTextStyles.bodyText1.copyWith(
                                        color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      )
                                    ),
                                    TextSpan(
                                      text: notification.description,
                                      style: AppTextStyles.bodyText1.copyWith(
                                        color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      )
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

Widget buildCategoryButton(BuildContext context, WidgetRef ref, String label, bool isSelected, Widget? destination) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final isSelected = selectedCategory == label;
  final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
  return OutlinedButton(
    style: AppButtonStyles.outlinedButton.copyWith(
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h)),
      backgroundColor: WidgetStateProperty.all(
        isSelected ? Colors.green[700] : isDarkMode ? Colors.black : Colors.white,
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
      // Navigate to the respective page if a destination is provided
      if (destination != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      }
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
