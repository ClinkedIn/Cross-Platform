import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// A class that contains constants used throughout the app.
/// This includes default image paths, API endpoints, and server URLs.
class Constants {
  static const String defaultProfileImage =
      'assets/images/default_profile_photo.png';
  static const String defaultCoverPhoto =
      'assets/images/default_cover_photo.jpeg';

  // Server URLs
  static const String _emulatorUrl = "http://10.0.2.2:3000/api";
  static const String _physicalDeviceUrl =
      "http://192.168.1.23:3000/api"; // Your actual IP address

  // Base API path
  static const String baseApiPath = '/api';

  // We'll use this as the baseUrl getter until we know for sure
  static String baseUrl = _physicalDeviceUrl; // Default to physical device URL

  // Initialize method to be called at app startup
  static Future<void> initializeBaseUrl() async {
    try {
      debugPrint('⚠️ Current baseUrl: $baseUrl');

      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;

        if (!androidInfo.isPhysicalDevice) {
          baseUrl = _emulatorUrl;
          debugPrint('⚠️ Using emulator URL: $baseUrl');
        } else {
          baseUrl = _physicalDeviceUrl;
          debugPrint('⚠️ Using physical device URL: $baseUrl');
        }
      } else if (Platform.isIOS) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final iosInfo = await deviceInfoPlugin.iosInfo;

        if (!iosInfo.isPhysicalDevice) {
          baseUrl = _emulatorUrl;
          debugPrint('⚠️ Using iOS simulator URL: $baseUrl');
        } else {
          baseUrl = _physicalDeviceUrl;
          debugPrint('⚠️ Using iOS physical device URL: $baseUrl');
        }
      }

      debugPrint('⚠️ FINAL API BASE URL: $baseUrl');
      debugPrint(
        '⚠️ To connect to the API server, make sure it\'s running at $baseUrl',
      );
    } catch (e) {
      debugPrint('⚠️ Error initializing baseUrl: $e');
      baseUrl = _physicalDeviceUrl;
      debugPrint('⚠️ Using fallback URL: $baseUrl');
    }
  }

  // Authentication endpoints
  static const String loginEndpoint = '$baseApiPath/user/login';
  static const String getUserDataEndpoint = '$baseApiPath/user/me';
  static const String registerEndpoint = '$baseApiPath/user/';
  static const String createUserProfileEndpoint = '$baseApiPath/user/profile';
  static const String logoutEndpoint = '$baseApiPath/user/logout';

  static const String forgotPasswordEndpoint =
      '$baseApiPath/user/forgot-password';
  static const String verifyResetPasswordOtpEndpoint =
      '$baseApiPath/user/verify-reset-password-otp';
  static const String resetPasswordEndpoint =
      '$baseApiPath/user/reset-password';

  // Post/feed endpoints
  static const String feedEndpoint = '$baseApiPath/posts';

  // Chat endpoints
  static const String allChatsEndpoint = '$baseApiPath/chats/all-chats';
  static const String chatMarkAsReadEndpoint =
      '$baseApiPath/chats/mark-as-read';
  static const String chatMarkAsUnreadEndpoint =
      '$baseApiPath/chats/mark-as-unread';
  static const String chatConversationEndpoint =
      '$baseApiPath/chats/direct-chat/{chatId}';
  static const String chatMessagesEndpoint = '$baseApiPath/messages';

  static const String savePostEndpoint =
      '$baseApiPath/posts/%s/save'; // %s will be replaced with the postId
  static const String togglelikePostEndpoint =
      '$baseApiPath/posts/%s/like'; // %s will be replaced with the postId
  static const String createPostEndpoint = '$baseApiPath/posts';
  static const String postDetailEndpoint =
      '$baseApiPath/posts/%s'; // %s will be replaced with the postId
  static const String commentsEndpoint =
      '$baseApiPath/comments/%s/post'; // %s will be replaced with the postId
  static const String addCommentEndpoint =
      '$baseApiPath/comments'; // %s will be replaced with the postId
  static const String RepostEndpoint =
      '$baseApiPath/posts/%s/repost'; // %s will be replaced with the postId
  //static const String unlikePostEndpoint = '$baseApiPath/posts/%s/unlike'; // %s will be replaced with the postId

  // Notifications endpoints
  static const String getNotificationsEndpoint = '$baseApiPath/notifications';
  static const String markNotificationAsReadEndpoint =
      '$baseApiPath/notifications/mark-read/%s'; // %s will be replaced with the notificationId
  static const String markNotificationAsUnreadEndpoint =
      '$baseApiPath/notifications/mark-unread/%s'; // %s will be replaced with the notificationId
  static const String getNotificationsUnreadCountEndpoint =
      '$baseApiPath/notifications/unread-count';
  static const String pauseNotificationsEndpoint =
      '$baseApiPath/notifications/pause-notifications';
  static const String resumeNotificationsEndpoint =
      '$baseApiPath/notifications/resume-notifications';
  static const String restoreNotificationsEndpoint =
      '$baseApiPath/notifications/restore-notification/%s'; // %s will be replaced with the notificationId
  static const String deleteNotificationEndpoint =
      '/notifications/%s'; // %s will be replaced with the notificationId
  static const String deletePostEndpoint = 
      '/posts/%s'; // %s will be replaced with the postId
  static const String editPostEndpoint = '/posts/%s'; 
  // Add these constants after the other endpoint definitions
  static const String reportPostEndpoint = 
    '/posts/%s/report'; // %s will be replaced with the postId
  static const String searchUsersEndpoint = '/search/users';
  static const String googleLoginEndpoint = '/user/auth/google';


      '$baseApiPath/notifications/%s'; // %s will be replaced with the notificationId

  static const String deletePostEndpoint =
      '$baseApiPath/posts/%s'; // %s will be replaced with the postId

}
