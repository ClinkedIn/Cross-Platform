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
      "http://192.168.1.17:3000/api"; // Your actual IP address


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
  static const String loginEndpoint = '/user/login';
  static const String getUserDataEndpoint = '/user/me';
  static const String registerEndpoint = '/user/';
  static const String createUserProfileEndpoint = '/user/profile';
  static const String logoutEndpoint = '/user/logout';

  static const String forgotPasswordEndpoint = '/user/forgot-password';
  static const String verifyResetPasswordOtpEndpoint =
      '/user/verify-reset-password-otp';
  static const String resetPasswordEndpoint = '/user/reset-password';

  // Post/feed endpoints
  static const String feedEndpoint = '/posts';

  // Chat endpoints
  static const String allChatsEndpoint = '/chats/all-chats';
  static const String chatMarkAsReadEndpoint = '/chats/mark-as-read';
  static const String chatMarkAsUnreadEndpoint = '/chats/mark-as-unread';

  static const String chatGetUnreadCount = '/messages/unread-count';

  /// Endpoint to fetch a specific chat conversation
  /// Use: '/chats/direct-chat/{actualChatId}'
  static const String chatConversationEndpoint = '/chats/direct-chat/{chatId}';
  
  /// Block and Unblock endpoints 
  static const String blockUserEndpoint = '/messages/block-user/{userId}';
  static const String unblockUserEndpoint = '/messages/unblock-user/{userId}';
  static const String isUserBlocked = '/messages/is-blocked-from-messaging/{userId}';

  

  static const String chatMessagesEndpoint = '/messages';

  static const String savePostEndpoint =
      '/posts/%s/save'; // %s will be replaced with the postId
  static const String togglelikePostEndpoint =
      '/posts/%s/like'; // %s will be replaced with the postId
  static const String createPostEndpoint = '/posts';
  static const String postDetailEndpoint =
      '/posts/%s'; // %s will be replaced with the postId
  static const String commentsEndpoint =
      '/comments/%s/post'; // %s will be replaced with the postId
  static const String addCommentEndpoint =
      '/comments'; // %s will be replaced with the postId
  static const String RepostEndpoint =
      '/posts/%s/repost'; // %s will be replaced with the postId
  //static const String unlikePostEndpoint = '/posts/%s/unlike'; // %s will be replaced with the postId

  // Notifications endpoints
  static const String getNotificationsEndpoint = '/notifications';
  static const String markNotificationAsReadEndpoint =
      '/notifications/mark-read/%s'; // %s will be replaced with the notificationId
  static const String markNotificationAsUnreadEndpoint =
      '/notifications/mark-unread/%s'; // %s will be replaced with the notificationId
  static const String getNotificationsUnreadCountEndpoint =
      '/notifications/unread-count';
  static const String pauseNotificationsEndpoint =
      '/notifications/pause-notifications';
  static const String resumeNotificationsEndpoint =
      '/notifications/resume-notifications';
  static const String restoreNotificationsEndpoint =
      '/notifications/restore-notification/%s'; // %s will be replaced with the notificationId
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
  // Add this constant to the Constants class
  static const String getPostLikesEndpoint = '/posts/%s/like'; // %s will be replaced with the postId
  static const String getsavedendpoint = '/user/saved-posts';
  // some Company endpoints
  static const String getCompanyFollowersEndpoint = '/companies/%s/follow'; // %s will be replaced with the companyId
  static String getCompanyAnalyticsEndpointFormatted({
    required String companyId,
    required String startDate,
    required String endDate,
    required String interval,
  }) {
    return '/companies/$companyId/analytics?startDate=$startDate&endDate=$endDate&interval=$interval';
  }

}
