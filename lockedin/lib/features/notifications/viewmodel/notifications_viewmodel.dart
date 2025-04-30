import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
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

  NotificationModel? deletedNotification, showLessNotification;
  int? deletedNotificationIndex,
      showLessNotificationIndex; // For undo deleting notification

  Map<String, NotificationModel> showLessNotifications =
      {}; // For show less like this

  /// Fetches the list of notifications from the backend.
  Future<void> fetchNotifications() async {
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
          isSeen: true, //must be seen if read
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
  // will deep link with the home page later to navigate to the post
  void navigateToPost(BuildContext context) {
    //int index needed as well

    //final notification = state[index]; // ✅ Navigate to the related post
    context.go("/notifications");
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
    final currentNotifications = state.value ?? [];

    final target = currentNotifications.firstWhere(
      (n) => n.id == id,
      orElse: NotificationModel.empty,
    );
    if (target.id == "") {
      print("Notification with id $id not found.");
      return;
    }

    deletedNotification = target;
    deletedNotificationIndex = currentNotifications.indexOf(target);

    try {
      final response = await RequestService.delete(
        Constants.deleteNotificationEndpoint.replaceAll("%s", id),
      );

      if (response.statusCode == 204) {
        print("✅ Notification $id deleted.");

        final updatedNotifications = List<NotificationModel>.from(
          currentNotifications,
        )..removeAt(deletedNotificationIndex!);

        state = AsyncValue.data(updatedNotifications);
      } else {
        print(
          "❌ Failed to delete notification. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Error during delete operation: $e");
    }
  }

  /// Undoes the deletion of the most recently deleted notification.
  void undoDeleteNotification() async {
    if (deletedNotification == null || deletedNotificationIndex == null) {
      print("No notification to undo delete.");
      return;
    }

    try {
      final response = await RequestService.patch(
        Constants.restoreNotificationsEndpoint.replaceAll(
          "%s",
          deletedNotification!.id,
        ),
        body: {},
      );

      if (response.statusCode == 200) {
        final currentNotifications = state.value ?? [];
        final updatedNotifications = List<NotificationModel>.from(
          currentNotifications,
        )..insert(deletedNotificationIndex!, deletedNotification!);

        state = AsyncValue.data(updatedNotifications);

        deletedNotification = null;
        deletedNotificationIndex = null;

        print("✅ Notification restored.");
      } else {
        print(
          "❌ Failed to restore notification. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Error during restore operation: $e");
    }
  }

  /// Replaces a notification with a "Show less like this" placeholder.
  void showLessLikeThis(String id) {
    final notifications = state.value ?? [];

    final target = notifications.firstWhere(
      (n) => n.id == id,
      orElse: () => NotificationModel.empty(),
    );
    if (target.id == "") return;

    showLessNotifications[id] = target;
    final index = notifications.indexOf(target);

    final updatedNotifications =
        List<NotificationModel>.from(notifications)
          ..removeAt(index)
          ..insert(
            index,
            NotificationModel(
              id: id,
              from: "",
              to: "",
              subject: "Show less like this",
              content: "Show less like this",
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isPlaceholder: true,
              sendingUser: SendingUser.empty(),
            ),
          );

    state = AsyncValue.data(updatedNotifications);
  }

  /// Undoes the "show less like this" action and restores the original notification.
  void undoShowLessLikeThis(String id) {
    if (!showLessNotifications.containsKey(id)) {
      print("No notification to undo show less like this.");
      return;
    }

    final originalNotification = showLessNotifications[id];
    if (originalNotification == null) return;

    final currentNotifications = state.value ?? [];
    final updatedNotifications = List<NotificationModel>.from(
      currentNotifications,
    );

    final index = updatedNotifications.indexWhere(
      (n) => n.id == id && n.isPlaceholder,
    );

    if (index != -1) {
      updatedNotifications[index] = originalNotification;

      state = AsyncValue.data(updatedNotifications);
      showLessNotifications.remove(id);

      print("✅ Reverted 'show less like this' for notification $id.");
    } else {
      print("⚠️ Placeholder not found for notification $id.");
    }
  }
}

// ✅ Riverpod Provider (no change)
/// A Riverpod provider that exposes the [NotificationsViewModel] to the app.
final notificationsProvider = StateNotifierProvider<
  NotificationsViewModel,
  AsyncValue<List<NotificationModel>>
>((ref) => NotificationsViewModel());
