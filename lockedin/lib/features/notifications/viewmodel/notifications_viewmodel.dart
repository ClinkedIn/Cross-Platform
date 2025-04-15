import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
//import 'package:lockedin/features/home_page/model/post_model.dart';
//import 'package:lockedin/features/home_page/view/home_page.dart';
//import 'package:lockedin/features/profile/widgets/post_card.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'dart:convert';

/// A [StateNotifier] that manages notification state for the app.
///
/// Handles fetching, updating, deleting, and hiding notifications.
///
/// This ViewModel uses Riverpod's `AsyncValue` to manage async state.

class NotificationsViewModel
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  /// Initializes the ViewModel by loading notifications from the API.
  NotificationsViewModel() : super(AsyncValue.loading()) {
    fetchNotifications();
  }

  /// Base URL of the mock server.

  final baseUrl = "https://a5a7a475-1f05-430d-a300-01cdf67ccb7e.mock.pstmn.io";

  NotificationModel? deletedNotification, showLessNotification;
  int? deletedNotificationIndex,
      showLessNotificationIndex; // For undo deleting notification

  Map<String, NotificationModel> showLessNotifications =
      {}; // For show less like this

  /// Fetches the list of notifications from the backend.
  Future<void> fetchNotifications() async {
    //final url = Uri.parse("$baseUrl/notifications");
    //final url = RequestService.get("/notifications");

    try {
      final response = await RequestService.get(
        Constants.getNotificationsEndpoint,
      );
      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        //final List<dynamic> data = decoded['notifications'];
        final notifications =
            decoded
                .map((notification) => NotificationModel.fromJson(notification))
                .toList();
        state = AsyncValue.data(
          notifications,
        ); // ✅ Update state correctly so UI rebuilds
      } else {
        state = AsyncValue.error(
          "Error: ${response.statusCode}",
          StackTrace.current,
        );
        //print("Error: ${response.statusCode}");
      }
    } catch (error) {
      state = AsyncValue.error(
        "Error fetching notifications: $error",
        StackTrace.current,
      );
      //print("Error fetching notifications: $error");
    }
  }

  /// Marks a specific notification as read.
  ///
  /// [id] is the ID of the notification to update.
  Future<void> markAsRead(String id) async {
    // final url = Uri.parse("$baseUrl/$id/read");

    try {
      final response = await RequestService.patch(
        Constants.markNotificationAsReadEndpoint.replaceAll("%s", id),
        body: {},
      );
      if (response.statusCode == 200) {
        final updatedNotifications = List<NotificationModel>.from(
          state.asData?.value ?? [],
        );
        final index = updatedNotifications.indexWhere(
          (notification) => notification.id == id,
        );
        if (index == -1) {
          //print("Error! Notification with id $id not found.");
          return; // ✅ Check if the notification exists
        }
        final notification = updatedNotifications[index];
        updatedNotifications[index] = NotificationModel(
          id: notification.id,
          from: notification.from,
          to: notification.to,
          subject: notification.subject,
          content: notification.content,
          createdAt: notification.createdAt,
          updatedAt: notification.updatedAt,
          resourceId: notification.resourceId,
          relatedPostId: notification.relatedPostId,
          relatedCommentId: notification.relatedCommentId,
          isRead: true, // ✅ Mark as read
          isSeen: notification.isSeen,
          isPlaceholder: notification.isPlaceholder,
          sendingUser: notification.sendingUser,
        );

        state = AsyncValue.data(
          updatedNotifications,
        ); // Update the state with the modified list
        //print("✅ Notification $id marked as read.");
      } else {
        //print("❌ Failed to mark as read. Status: ${response.statusCode}");
      }
    } catch (error) {
      //print("❌Error marking notification as read: $error");
    }
  }

  /// Navigates the user to the post related to a notification.
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

  /// Marks all notifications as seen (for UI highlighting).
  void markAllAsSeen() {
    state = state.whenData((notifications) {
      for (var notification in notifications) {
        notification.isSeen = true;
      }
      return notifications;
    });
  }

  /// Returns the count of unseen notifications.
  Future<int> getUnreadNotificationsCount() async {
    final response = await RequestService.get(
      Constants.getNotificationsUnreadCountEndpoint,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final int unseenCount = decoded['unreadCount'];
      return unseenCount; // ✅ Return the unseen count
    } else {
      //print("Error: ${url.statusCode}");
      return 0; // ✅ Return 0 if there's an error
    }
  }

  /// Deletes a notification by its [id].
  void deleteNotification(String id) async {
    print("entered delete");

    final notifications = state.value ?? [];

    // Check if the notification exists
    deletedNotification = notifications.firstWhere(
      (notification) => notification.id == id,
      orElse:
          () => NotificationModel(
            id: "",
            from: "",
            to: "",
            subject: "",
            content: "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            resourceId: "",
            relatedPostId: "",
            relatedCommentId: "",
            isRead: false,
            isSeen: false,
            isPlaceholder: false,
            sendingUser: SendingUser(
              email: "",
              firstName: "",
              lastName: "",
              profilePicture: "",
            ),
          ),
    );

    // If the notification is found, delete it from the list
    if (deletedNotification?.id != "") {
      deletedNotificationIndex = notifications.indexOf(deletedNotification!);

      try {
        final response = await RequestService.delete(
          Constants.deleteNotificationEndpoint.replaceAll("%s", id),
        );

        if (response.statusCode == 200) {
          // Create a new list without the deleted notification
          print("✅ Notification $id deleted.");
          final updatedNotifications = List<NotificationModel>.from(
            notifications,
          )..removeAt(deletedNotificationIndex!);

          // Update the state with the new list
          state = AsyncValue.data(updatedNotifications);
        } else {
          print(
            "❌ Failed to delete notification. Status: ${response.statusCode}",
          );
        }
      } catch (e) {
        print("❌ Error during delete operation: $e");
      }
    } else {
      print("Notification with id $id not found.");
    }
  }

  /// Undoes the deletion of the most recently deleted notification.
  void undoDeleteNotification() {
    if (deletedNotification != null && deletedNotificationIndex != null) {
      state.whenData((notifications) async {
        final response = await RequestService.patch(
          Constants.restoreNotificationsEndpoint.replaceAll(
            "%s",
            deletedNotification!.id,
          ),
          body: {},
        );
        if (response.statusCode == 200) {
          // Create a new list with the deleted notification added back
          final updatedNotifications = List<NotificationModel>.from(
            notifications,
          );
          updatedNotifications.insert(
            deletedNotificationIndex!,
            deletedNotification!,
          );
          // Update the state with the new list
          state = AsyncValue.data(updatedNotifications);
          // ✅ Clear the deleted notification to prevent duplicate undo
          deletedNotification = null;
          deletedNotificationIndex = null;
        } else {
          //print("❌ Failed to restore notification. Status: ${response.statusCode}");
        }
      });
    } else {
      //print("No notification to undo delete.");
    }
  }

  /// Replaces a notification with a "Show less like this" placeholder.
  void showLessLikeThis(String id) {
    state.whenData((notifications) {
      // Check if the notification exists
      showLessNotification = notifications.firstWhere(
        (notification) => notification.id == id,
        orElse:
            () => NotificationModel(
              id: "",
              from: "",
              to: "",
              subject: "",
              content: "",
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              resourceId: "",
              relatedPostId: "",
              relatedCommentId: "",
              isRead: false,
              isSeen: false,
              isPlaceholder: false,
              sendingUser: SendingUser(
                email: "",
                firstName: "",
                lastName: "",
                profilePicture: "",
              ),
            ),
      );

      // If the notification is found, delete it from the list
      if (showLessNotification?.id != "") {
        showLessNotificationIndex = notifications.indexOf(
          showLessNotification!,
        );
        showLessNotifications[showLessNotification!.id] = showLessNotification!;
        // Create a new list without the deleted notification
        final updatedNotifications =
            notifications
                .where((notification) => notification.id != id)
                .toList();
        updatedNotifications.insert(
          showLessNotificationIndex!,
          NotificationModel(
            id: id,
            from: "",
            to: "",
            subject: "Show less like this",
            content: "Show less like this",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            resourceId: "",
            relatedPostId: "",
            relatedCommentId: "",
            isRead: false,
            isSeen: false,
            isPlaceholder: true, // ✅ Mark as a placeholder
            sendingUser: SendingUser(
              email: "",
              firstName: "",
              lastName: "",
              profilePicture: "",
            ),
          ),
        );
        // Update the state with the new list
        state = AsyncValue.data(updatedNotifications);

        // Optionally, you can also make an API call to delete the notification from the server
        // final url = Uri.parse("$baseUrl/notifications/$id");
        // await http.delete(url);
      } else {
        //print("Notification with id $id not found.");
      }
    });
  }

  /// Undoes the "show less like this" action and restores the original notification.
  void undoShowLessLikeThis(String id) {
    if (showLessNotifications.isNotEmpty) {
      final originalNotification = showLessNotifications[id];
      if (originalNotification == null) {
        return;
      }
      state.whenData((notifications) {
        // Create a new list with the deleted notification added back
        final updatedNotifications = List<NotificationModel>.from(
          notifications,
        );
        final index = updatedNotifications.indexWhere(
          (n) => n.id == id && n.isPlaceholder,
        );
        if (index != -1) {
          updatedNotifications[index] = originalNotification;
          state = AsyncValue.data(updatedNotifications);
          showLessNotifications.remove(id);
        } // ✅ Remove only this one
      });
    } else {
      //print("No notification to undo show less like this.");
    }
  }
}

// ✅ Riverpod Provider (no change)
/// A Riverpod provider that exposes the [NotificationsViewModel] to the app.
final notificationsProvider = StateNotifierProvider<
  NotificationsViewModel,
  AsyncValue<List<NotificationModel>>
>((ref) => NotificationsViewModel());
