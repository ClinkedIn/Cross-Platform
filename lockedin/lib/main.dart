import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';

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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Get the auth service and check if user is logged in
      final authService = ref.read(authServiceProvider);
      
      // Try to fetch user data, this will automatically use demo mode if needed
      final user = await authService.fetchCurrentUser();
      
      if (user != null) {
        debugPrint('User initialized: ${user.id}');
        if (authService.isDemoMode) {
          debugPrint('⚠️ USING DEMO MODE - Messages will use a fake user ID');
        }
      } else {
        debugPrint('No user available, enabling demo mode');
        authService.enableDemoMode();
      }
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      // If any error occurs, enable demo mode
      final authService = ref.read(authServiceProvider);
      authService.enableDemoMode();
      
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    // Show loading indicator while initializing
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LockedIn',
      theme: theme,
      home: LoginPage(), // Change this to LoginPage() to show the login page
    );
  }
}
