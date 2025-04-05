import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
//import 'package:lockedin/features/home_page/model/post_model.dart';
//import 'package:lockedin/features/home_page/view/home_page.dart';
//import 'package:lockedin/features/profile/widgets/post_card.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationsViewModel extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsViewModel() : super(AsyncValue.loading()) {
    fetchNotifications();
  }
  final baseUrl = "https://a5a7a475-1f05-430d-a300-01cdf67ccb7e.mock.pstmn.io";

  NotificationModel? deletedNotification;
  int? deletedNotificationIndex; // For undo deleting notification
  //////// Needed to add a map for deleted notifications and show less to handle more than one ////////

  Future<void> fetchNotifications() async {
    final url = Uri.parse("$baseUrl/notifications");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['notifications'];
        //print('first id of notification: ${data[0]['id']}');
        final notifications =
            data
                .map((notification) => NotificationModel.fromJson(notification))
                .toList();
        state = AsyncValue.data(notifications); // ✅ Update state correctly so UI rebuilds
      } else {
        state = AsyncValue.error("Error: ${response.statusCode}", StackTrace.current);
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      state = AsyncValue.error("Error fetching notifications: $error", StackTrace.current);
      print("Error fetching notifications: $error");
    }
  }

  Future<void> markAsRead(int id) async {
    final url = Uri.parse("$baseUrl/$id/read");

    try {
      final response = await http.patch(url);
      if (response.statusCode == 200) {
        final updatedNotifications = List<NotificationModel>.from(state.asData?.value ?? []);
        final index = updatedNotifications.indexWhere(
          (notification) => notification.id == id,
        );
        if (index == -1) {
          print("Error! Notification with id $id not found.");
          return; // ✅ Check if the notification exists
        }
        final notification = updatedNotifications[index];
        updatedNotifications[index] = NotificationModel(
          id: notification.id,
          username: notification.username,
          activityType: notification.activityType,
          description: notification.description,
          timeAgo: notification.timeAgo,
          profileImageUrl: notification.profileImageUrl,
          isRead: true, // ✅ Mark as read
          isSeen: notification.isSeen, // Keep the isSeen state unchanged
          secondUsername: notification.secondUsername,
        );

        state = AsyncValue.data(updatedNotifications); // Update the state with the modified list
        //print("✅ Notification $id marked as read.");
      } else {
        //print("❌ Failed to mark as read. Status: ${response.statusCode}");
      }
    } catch (error) {
      //print("❌Error marking notification as read: $error");
    }
  }

  void navigateToPost(BuildContext context) {
    //int index needed as well

    //final notification = state[index]; // ✅ Navigate to the related post
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(),
        //     PostCard(
        //   post: PostModel(
        //     id: '1',
        //     userId: '100',
        //     username: 'Test User 1',
        //     profileImageUrl: 'https://i.pravatar.cc/150?img=10',
        //     content: 'This is a test post',
        //     time: '2d',
        //     isEdited: false,
        //     imageUrl: 'https://picsum.photos/800/600?random=1',
        //     likes: 10,
        //     comments: 3,
        //     reposts: 2,
        //   ),
        //   onLike: () {},
        //   onComment: () {},
        //   onShare: () {},
        //   onFollow: () {},
        // ),
      ),
    );
  }

  void markAllAsSeen() {
    state = state.whenData((notifications) {
      for (var notification in notifications) {
        notification.isSeen = true;
      }
      return notifications;
    });
  }

  AsyncValue<int> getUnseenNotificationsCount() {
    return state.when(
      data: (notifications) {
        final unseenCount = notifications.where((notification) => !notification.isSeen).length;
        return AsyncValue.data(unseenCount);
      },
      loading: () => AsyncValue.data(0), // Default to 0 when loading
      error: (error, stackTrace) => AsyncValue.data(0), // Default to 0 in case of error
    );
  }
    // final url = Uri.parse("$baseUrl/notifications/unseenCount");
    // try {
    //   final response = await http.get(url);
    //   if (response.statusCode == 200) {
    //     final Map<String, dynamic> decoded = jsonDecode(response.body);
    //     final int unseenCount = decoded['unseenCount'];
    //     return unseenCount; // ✅ Return the unseen count
    //   } else {
    //     print("Error: ${response.statusCode}");
    //     return 0; // ✅ Return 0 if there's an error
    //   }
    // }
    // catch (error) {
    //   print("Error fetching unseen notifications count: $error");
    //   return 0; // ✅ Return 0 if there's an error
    // }

  void deleteNotification(int id) {
    state.whenData((notifications) {
      // Check if the notification exists
      deletedNotification = notifications.firstWhere(
        (notification) => notification.id == id,
        orElse: () => NotificationModel(
          id: -1,
          username: '',
          activityType: '',
          description: '',
          timeAgo: '',
          profileImageUrl: '',
          isRead: false,
          isSeen: false,
          secondUsername: '',
        ),
      );

      // If the notification is found, delete it from the list
      if (deletedNotification?.id != -1) {
        deletedNotificationIndex = notifications.indexOf(deletedNotification!);

        // Create a new list without the deleted notification
        final updatedNotifications = notifications.where((notification) => notification.id != id).toList();

        // Update the state with the new list
        state = AsyncValue.data(updatedNotifications);

        // Optionally, you can also make an API call to delete the notification from the server
        // final url = Uri.parse("$baseUrl/notifications/$id");
        // await http.delete(url);
      } else {
        print("Notification with id $id not found.");
      }
    });
  }

  void undoDeleteNotification() {
    if (deletedNotification != null && deletedNotificationIndex != null) {
      state.whenData((notifications) {
        // Create a new list with the deleted notification added back
        final updatedNotifications = List<NotificationModel>.from(notifications);
        updatedNotifications.insert(deletedNotificationIndex!, deletedNotification!);
        // Update the state with the new list
        state = AsyncValue.data(updatedNotifications);
        // ✅ Clear the deleted notification to prevent duplicate undo
        deletedNotification = null;
        deletedNotificationIndex = null;
      });
    } else {
      //print("No notification to undo delete.");
    }
  }

  void showLessLikeThis(int id) {
    state.whenData((notifications) {
      // Check if the notification exists
      deletedNotification = notifications.firstWhere(
        (notification) => notification.id == id,
        orElse: () => NotificationModel(
          id: -1,
          username: '',
          activityType: '',
          description: '',
          timeAgo: '',
          profileImageUrl: '',
          isRead: false,
          isSeen: false,
          secondUsername: '',
        ),
      );

      // If the notification is found, delete it from the list
      if (deletedNotification?.id != -1) {
        deletedNotificationIndex = notifications.indexOf(deletedNotification!);

        // Create a new list without the deleted notification
        final updatedNotifications = notifications.where((notification) => notification.id != id).toList();
        updatedNotifications.insert(deletedNotificationIndex!, NotificationModel(
          id: -1, 
          username: "", 
          activityType: "", 
          description: "", 
          timeAgo: "0m",
          profileImageUrl: "",
          isPlaceholder: true));
        // Update the state with the new list
        state = AsyncValue.data(updatedNotifications);

        // Optionally, you can also make an API call to delete the notification from the server
        // final url = Uri.parse("$baseUrl/notifications/$id");
        // await http.delete(url);
      } else {
        print("Notification with id $id not found.");
      }
    });
  }

  void undoShowLessLikeThis() {
    if (deletedNotification != null && deletedNotificationIndex != null) {
      state.whenData((notifications) {
        // Create a new list with the deleted notification added back
        if (notifications[deletedNotificationIndex!].isPlaceholder) {
          final updatedNotifications = List<NotificationModel>.from(notifications);  
          updatedNotifications.removeAt(deletedNotificationIndex!);
          updatedNotifications.insert(deletedNotificationIndex!, deletedNotification!);
          // Update the state with the new list
          state = AsyncValue.data(updatedNotifications);
          // ✅ Clear the deleted notification to prevent duplicate undo
          deletedNotification = null;
          deletedNotificationIndex = null;
        }
      });
    } else {
      //print("No notification to undo show less like this.");
    }
  }
}

// ✅ Riverpod Provider (no change)
final notificationsProvider =
    StateNotifierProvider<NotificationsViewModel, AsyncValue<List<NotificationModel>>>(
      (ref) => NotificationsViewModel(),
    );
