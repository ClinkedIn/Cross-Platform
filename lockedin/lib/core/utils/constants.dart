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
  static const String _physicalDeviceUrl = "http://192.168.1.23:3000"; // Replace with your actual IP
  
  // We'll use this as the baseUrl getter until we know for sure
  static String baseUrl = _physicalDeviceUrl; // Default to physical device URL
  
  // Initialize method to be called at app startup
  static Future<void> initializeBaseUrl() async {
    try {
      debugPrint('Current baseUrl: $baseUrl');
      
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        
        // If it's an emulator, use the emulator URL
        if (!androidInfo.isPhysicalDevice) {
          baseUrl = _emulatorUrl;
          debugPrint('Using emulator URL: $baseUrl');
        } else {
          baseUrl = _physicalDeviceUrl;
          debugPrint('Using physical device URL: $baseUrl');
        }
      }
      // For iOS or other platforms, keep using the physical device URL
    } catch (e) {
      debugPrint('Error initializing baseUrl: $e');
      // Fallback to default
      baseUrl = _physicalDeviceUrl;
    }
  }

  // Authentication endpoints
  static const String loginEndpoint = '/user/login';
  static const String getUserDataEndpoint = "/user/me";
  static const String registerEndpoint = '/user/';
  static const String createUserProfileEndpoint = '/user/profile';
  static const String logoutEndpoint = '/user/logout';
  static const String forgotPasswordEndpoint = '/user/forgot-password';
  
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
}