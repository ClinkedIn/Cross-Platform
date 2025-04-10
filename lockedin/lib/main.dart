import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lockedin/features/auth/view/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: MainPage(), // Change this to LoginPage() to show the login page
    );
  }
}
