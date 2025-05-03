import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'dart:convert';

class MainPage extends ConsumerStatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetchProfile();
    });
  }

  Future<void> _checkAuthAndFetchProfile() async {
    if (!mounted) return;

    final timeoutTimer = Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading && mounted) {
        _handleInvalidToken("Loading timeout - token might be invalid");
      }
    });

    try {
      final hasCookie = await TokenService.hasCookie();

      if (!hasCookie) {
        if (!mounted) return;
        context.go('/login');
      } else {
        // Check token validity with a quick API call
        try {
          // Use a simple API endpoint that requires authentication
          final response = await RequestService.get('/user/me');

          if (response.statusCode == 200 || response.statusCode == 304) {
            // Token is valid, navigate to home
            final responseBody = jsonDecode(response.body);
            if (responseBody['user']['isSuperAdmin'] == true) {
              context.go('/admin-dashboard');
            } else {
              context.go('/home');
            }
          } else {
            // Token is invalid
            _handleInvalidToken(
              "Token validation failed: ${response.statusCode}",
            );
          }
        } catch (e) {
          // Request failed, token might be invalid
          _handleInvalidToken("API request failed: ${e.toString()}");
        }
      }
    } catch (e) {
      if (mounted) {
        _handleInvalidToken("Authentication error: ${e.toString()}");
      }
    } finally {
      // Cancel the timeout timer if we're done earlier
      timeoutTimer.ignore();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleInvalidToken(String reason) async {
    print("Invalid token detected: $reason");

    // Delete the potentially invalid token
    await TokenService.deleteCookie();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session expired. Please sign in again.';
      });

      // Short delay to show the error message before redirecting
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          context.go('/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading your profile...'),
            ] else if (_errorMessage.isNotEmpty) ...[
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 20),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              Text('Redirecting to login...'),
            ],
          ],
        ),
      ),
    );
  }
}
