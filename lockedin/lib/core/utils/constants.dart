import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class Constants {
  static const String defaultProfileImage =
      'assets/images/default_profile_photo.png';
  static const String defaultCoverPhoto =
      'assets/images/default_cover_photo.jpeg';
  
  // For now, keep the original baseUrl as a fallback
  static const String _emulatorUrl = "http://10.0.2.2:3000";
  static const String _physicalDeviceUrl = "http://192.168.1.23:3000"; // Replace with your actual IP
  
  // We'll use this as the baseUrl getter until we know for sure
  static String baseUrl = _physicalDeviceUrl; // Default to physical device URL
  
  // Initialize method to be called at app startup
  static Future<void> initializeBaseUrl() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      
      // If it's an emulator, use the emulator URL
      if (!androidInfo.isPhysicalDevice) {
        baseUrl = _emulatorUrl;
      } else {
        baseUrl = _physicalDeviceUrl;
      }
    }
    // For iOS or other platforms, keep using the physical device URL
  }

  static const String loginEndpoint = '/user/login';
  static const String getUserDataEndpoint = "/user/me";
  static const String registerEndpoint = '/user/';
  static const String createUserProfileEndpoint = '/user/profile';
  static const String logoutEndpoint = '/user/logout';
  static const String feedEndpoint = '/posts';
  static const String forgotPasswordEndpoint = '/user/forgot-password';
}