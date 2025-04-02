import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'package:lockedin/features/profile/widgets/post_card.dart';

class NotificationsViewModel extends StateNotifier<List<NotificationModel>> {
  NotificationsViewModel() : super([]) {
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating API call

    final notifications = [
      NotificationModel(
        id: "1",
        username: "Muhammad Salah",
        activityType: "posted",
        description: ": The assignment deadline has been postponed to next week. Eid Mubarak!",
        timeAgo: "9m",
        profileImageUrl: "https://img.a.transfermarkt.technology/portrait/header/148455-1727337594.jpg?lm=1",
      ),
      NotificationModel(
        id: "2",
        username: "Cristiano Ronaldo",
        activityType: "commented on",
        description: "congrats Omar, well deserved!",
        timeAgo: "39m",
        profileImageUrl: "https://img.a.transfermarkt.technology/portrait/header/8198-1694609670.jpg?lm=1",
      ),
      NotificationModel(
        id: "3",
        username: "Lionel Messi",
        activityType: "posted",
        description: ": The new update is live! Check it out.",
        timeAgo: "1h",
        profileImageUrl: "https://img.a.transfermarkt.technology/portrait/header/28003-1740766555.jpg?lm=1",
      ),
    ];

    state = notifications; // ✅ Update state correctly so UI rebuilds
  }

  void markAsReadAndNavigate(BuildContext context, int index) {
    state = state.map((notification) {
      if (state.indexOf(notification) == index) {
        return NotificationModel(
          id: notification.id,
          username: notification.username,
          activityType: notification.activityType,
          description: notification.description,
          timeAgo: notification.timeAgo,
          profileImageUrl: notification.profileImageUrl,
          isRead: true, // ✅ Mark as read
        );
      }
      return notification;
    }).toList();

    // ✅ Navigate to the related post
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostCard(
          post: PostModel(
            id: '1',
            userId: '100',
            username: 'Test User 1',
            profileImageUrl: 'https://i.pravatar.cc/150?img=10',
            content: 'This is a test post',
            time: '2d',
            isEdited: false,
            imageUrl: 'https://picsum.photos/800/600?random=1',
            likes: 10,
            comments: 3,
            reposts: 2,
          ),
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onFollow: () {},
        ),
      ),
    );
  }
}

// ✅ Riverpod Provider (no change)
final notificationsProvider =
    StateNotifierProvider<NotificationsViewModel, List<NotificationModel>>(
  (ref) => NotificationsViewModel(),
);
