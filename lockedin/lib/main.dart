import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the base URL before the app starts
  await Constants.initializeBaseUrl();
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LockedIn',
      theme: theme,
      home: LoginPage(), // Change this to LoginPage() to show the login page
    );
  }
}
