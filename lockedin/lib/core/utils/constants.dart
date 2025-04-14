import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class Constants {
  static const String defaultProfileImage =
      'assets/images/default_profile_photo.png';
  static const String defaultCoverPhoto =
      'assets/images/default_cover_photo.jpeg';
  
  // Server URLs
  static const String _emulatorUrl = "http://10.0.2.2:3000";
  static const String _physicalDeviceUrl = "http://192.168.1.23:3000"; // Your actual IP address
  
  // We'll use this as the baseUrl getter until we know for sure
  static String baseUrl = _physicalDeviceUrl; // Default to physical device URL
  
  // Initialize method to be called at app startup
  static Future<void> initializeBaseUrl() async {
    try {
      debugPrint('⚠️ Current baseUrl: $baseUrl');
      
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        
        // If it's an emulator, use the emulator URL
        if (!androidInfo.isPhysicalDevice) {
          baseUrl = _emulatorUrl;
          debugPrint('⚠️ Using emulator URL: $baseUrl');
        } else {
          baseUrl = _physicalDeviceUrl;
          debugPrint('⚠️ Using physical device URL: $baseUrl');
        }
      } else if (Platform.isIOS) {
        // For iOS simulator vs physical device
        final deviceInfoPlugin = DeviceInfoPlugin();
        final iosInfo = await deviceInfoPlugin.iosInfo;
        
        // Check if it's a simulator
        if (iosInfo.isPhysicalDevice == false) {
          baseUrl = _emulatorUrl;
          debugPrint('⚠️ Using iOS simulator URL: $baseUrl');
        } else {
          baseUrl = _physicalDeviceUrl;
          debugPrint('⚠️ Using iOS physical device URL: $baseUrl');
        }
      }
      // For other platforms, keep using the physical device URL
      
      debugPrint('⚠️ FINAL API BASE URL: $baseUrl');
      debugPrint('⚠️ To connect to the API server, make sure it\'s running at $baseUrl');
    } catch (e) {
      debugPrint('⚠️ Error initializing baseUrl: $e');
      // Fallback to default
      baseUrl = _physicalDeviceUrl;
      debugPrint('⚠️ Using fallback URL: $baseUrl');
    }
  }

  // Authentication endpoints
  static const String loginEndpoint = '/user/login';
  static const String getUserDataEndpoint = "/user/me";
  static const String registerEndpoint = '/user/';
  static const String createUserProfileEndpoint = '/user/profile';
  static const String logoutEndpoint = '/user/logout';

  static const String forgotPasswordEndpoint = '/user/forgot-password';
  static const String verifyResetPasswordOtpEndpoint = '/user/verify-reset-password-otp';
  static const String resetPasswordEndpoint = '/user/reset-password';
  
  // Post/feed endpoints
  static const String feedEndpoint = '/posts';

  
  // Chat endpoints
  /// Endpoint to fetch all chats for the current user
  static const String allChatsEndpoint = '/chats/all-chats';
  
  /// Endpoint to fetch a specific chat conversation
  /// Use: '/chats/direct-chat/{actualChatId}'
  static const String chatConversationEndpoint = '/chats/direct-chat/{chatId}';
  
  /// Endpoint to send a message to a specific chat
  /// Format: '/chats/direct-chat/{chatId}/messages' 
  static const String chatMessagesEndpoint = '/chats/direct-chat/{chatId}/messages';

  static const String savePostEndpoint = '/posts/%s/save'; // %s will be replaced with the postId
  static const String togglelikePostEndpoint = '/posts/%s/like'; // %s will be replaced with the postId
  static const String createPostEndpoint = '/posts';
  static const String postDetailEndpoint = '/posts/%s'; // %s will be replaced with the postId
  static const String commentsEndpoint = '/comments/%s/post'; // %s will be replaced with the postId
  static const String addCommentEndpoint = '/comments'; // %s will be replaced with the postId
  //static const String unlikePostEndpoint = '/posts/%s/unlike'; // %s will be replaced with the postId
  static const String getNotificationsEndpoint = '/notifications';
  static const String markNotificationAsReadEndpoint = '/notifications/mark-read/%s'; // %s will be replaced with the notificationId
  static const String markNotificationAsUnreadEndpoint = '/notifications/mark-unread/%s'; // %s will be replaced with the notificationId
  static const String getNotificationsUnreadCountEndpoint = '/notifications/unread-count';
  static const String pauseNotificationsEndpoint = '/notifications/pause-notifications';
  static const String resumeNotificationsEndpoint = '/notifications/resume-notifications';
  static const String restoreNotificationsEndpoint = '/notifications/restore-notification/%s'; // %s will be replaced with the notificationId
  static const String deleteNotificationEndpoint = '/notifications/%s'; // %s will be replaced with the notificationId
}

