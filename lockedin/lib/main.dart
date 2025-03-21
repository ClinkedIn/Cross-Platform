import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/auth/view/signup/sign_up_view.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:lockedin/features/auth/view/main_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: Sizer(
        // Wrap with Sizer for responsiveness
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
      home: LoginPage(),
    );
  }
}
