import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/routing.dart';

class MainPage extends ConsumerStatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetchProfile();
    });
  }

  Future<void> _checkAuthAndFetchProfile() async {
    if (!mounted) return;

    final hasCookie = await TokenService.hasCookie();

    if (!hasCookie) {
      if (!mounted) return;
      context.go('/login');
    } else {
      try {
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load user data: ${e.toString()}'),
            ),
          );
          // Still navigate to home on error
          context.go('/home');
        }
      }
    }
  }

  // Future<void> _checkAuthentication() async {
  //   if (!mounted) return;

  //   final hasCookie = await TokenService.hasCookie();

  //   if (!hasCookie) {
  //     if (!mounted) return;
  //     context.go('/login');
  //   } else {
  //     context.go('/home');
  //   }
  // }

  // Future<void> _fetchUserProfile() async {
  //   if (!mounted) return;

  //   try {
  //     // Fetch user data
  //     await ref.read(profileViewModelProvider).fetchUser(context);

  //     // Mark user data as loaded
  //     ref.read(userDataLoadedProvider.notifier).state = true;

  //     // Navigate to home
  //     if (mounted) {
  //       context.go('/home');
  //     }
  //   } catch (e) {
  //     // Handle error, possibly show an error message
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while data is being fetched
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading your profile...'),
          ],
        ),
      ),
    );
  }
}
