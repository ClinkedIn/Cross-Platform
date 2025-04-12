import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/routing.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lockedin/core/services/token_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the base URL before the app starts
  await Constants.initializeBaseUrl();

  // For development: Uncomment this line to force logout on hot restart
  await TokenService.deleteCookie();

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

      // Check if user is logged in first
      final isLoggedIn = await authService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('No auth token found, should navigate to login');
        // We'll set _isInitialized to true and let the router handle redirection 
        setState(() {
          _isInitialized = true;
        });
        return;
      }

      // Try to fetch user data
      final user = await authService.fetchCurrentUser();

      if (user != null) {
        debugPrint('User initialized: ${user.id}');
      } else {
        debugPrint('No authenticated user available, removing any stale tokens');
        // Clear any stale tokens
        await _clearAuthAndPrepareForLogin();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      // Clear auth on error
      await _clearAuthAndPrepareForLogin();
      
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  Future<void> _clearAuthAndPrepareForLogin() async {
    try {
      // Clear any existing auth tokens
      await TokenService.deleteCookie();
      debugPrint('Auth tokens cleared, user should be redirected to login');
    } catch (e) {
      debugPrint('Error clearing auth tokens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait until auth is initialized before building the app
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
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
