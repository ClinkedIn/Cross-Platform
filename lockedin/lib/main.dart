import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/routing.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import'package:lockedin/core/services/token_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the base URL before the app starts
  await Constants.initializeBaseUrl();

  // Initialize Firebase
  await Firebase.initializeApp();

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
    // Wait until auth is initialized before building the app

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
