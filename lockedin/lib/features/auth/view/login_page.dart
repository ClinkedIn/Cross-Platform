import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
import 'package:lockedin/features/auth/viewmodel/login_in_viewmodel.dart';
import 'package:lockedin/features/auth/view/forget%20Password/forgot_password_page.dart';
import 'package:lockedin/features/auth/view/signup/sign_up_view.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Listen to login state
    ref.listen<AsyncValue<void>>(loginViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Success case: Navigate to MainPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
        error: (error, stackTrace) {
          // Error case: Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
        loading: () {
          // Optional: Show loading indicator (handled below if needed)
        },
      );
    });

    return Scaffold(
      appBar: LogoAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Locked ",
                  style: AppTextStyles.headline1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
                  height: 30,
                ),
              ],
            ),
            const SizedBox(height: 42),
            Text("Sign in", style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("or ", style: AppTextStyles.bodyText2),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpView()),
                    );
                  },
                  child: Text(
                    "Join lockedIn",
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email or Phone",
                filled: true,
                fillColor: isDarkMode ? AppColors.black : AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: isDarkMode ? AppColors.black : AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                "Forgot password?",
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.elevatedButton,
              onPressed: () {
                ref.read(loginViewModelProvider.notifier).login(
                      _emailController.text,
                      _passwordController.text,
                    );
              },
              child: const Text("Sign in"),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("or"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: 3.h),
            Column(
              children: [
                AppButtonStyles.socialLoginButton(
                  text: "Sign in with Apple",
                  icon: Icons.apple,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                AppButtonStyles.socialLoginButton(
                  text: "Sign in with Google",
                  icon: Icons.g_mobiledata,
                  onPressed: () {
                    ref.read(loginViewModelProvider.notifier).signInWithGoogle();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}