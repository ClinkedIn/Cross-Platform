import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/routing.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lockedin/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:lockedin/features/notifications/notifications_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the base URL before the app starts
  // await Constants.initializeBaseUrl();

  // Initialize Firebase with options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Helper file for showing notifications
  await NotificationHelper.init();

  // Initialize push notification logic
  await _initializeFCM();

  runApp(
    ProviderScope(
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return const MyApp();
        },
      ),
    ),
  );
}

// Setup push notification logic
Future<void> _initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request user permission (especially important on iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Push notifications authorized');

    // Handle FCM token retrieval with proper iOS handling
    try {
      String? token;

      if (Platform.isIOS) {
        // For iOS, we need to wait for the APNs token to be available
        // Register with APNs first
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Wait for APNs registration to complete
        // This is the key fix - providing a delay for APNs to initialize
        await Future.delayed(const Duration(seconds: 1));

        final apnsToken = await messaging.getAPNSToken();
        print("🍎 APNs Token: $apnsToken");

        if (apnsToken != null) {
          // Now it's safe to get the FCM token
          token = await messaging.getToken();
        } else {
          print('⚠️ APNs token is null, FCM token retrieval may fail');
          // You might want to retry later or implement a more robust solution
        }
      } else {
        // For Android, we can directly get the FCM token
        token = await messaging.getToken();
      }

      print('🔑 FCM Token: $token');
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  } else {
    print('❌ Push notifications not authorized');
  }

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'No title';
    final body = message.notification?.body ?? 'No body';
    print('📩 Foreground message: $title - $body');
    NotificationHelper.showNotification(title, body);
  });

  // Notification opened app
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📬 Notification opened app: ${message.notification?.title}');
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final GoRouter router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'LockedIn',
      theme: theme,
      routerConfig: router,
    );
  }
}
