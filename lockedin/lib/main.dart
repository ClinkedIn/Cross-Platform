import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/home_page/view/home_page.dart';
import 'package:lockedin/features/jobs/view/jobs_page.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

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
      home: JobsPage(),
    );
  }
}
