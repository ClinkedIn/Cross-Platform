import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/routing.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:lockedin/features/notifications/notifications_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the base URL before the app starts
  await Constants.initializeBaseUrl();

  // Initialize Firebase with options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Helper file for showing notifications
  //await NotificationHelper.init();

  // Initialize push notification logic
 // await _initializeFCM();

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
// Future<void> _initializeFCM() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Request user permission
//   NotificationSettings settings = await messaging.requestPermission();

//   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     print('✅ Push notifications authorized');
//   } else {
//     print('❌ Push notifications not authorized');
//   }

//   // Get FCM token
//   String? token = await messaging.getToken();
//   print('🔑 FCM Token: $token');

//   // Listen for foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('📩 Foreground message: ${message.notification?.title}');
//     final title = message.notification?.title ?? 'No title';
//     final body = message.notification?.body ?? 'No body';
//     NotificationHelper.showNotification(title, body);
//   });

//   // App opened from background notification
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('📬 Notification opened app: ${message.notification?.title}');
//   });
// }

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
