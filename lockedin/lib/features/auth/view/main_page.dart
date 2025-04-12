import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/token_services.dart';

class MainPage extends ConsumerStatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
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
          context.go('/home');
        }
      }
    }
  }

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
