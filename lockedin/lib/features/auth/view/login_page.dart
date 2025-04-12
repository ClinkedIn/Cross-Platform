import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/auth/viewmodel/login_in_viewmodel.dart';
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

    return Scaffold(
      appBar: LogoAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 42),

            Text("Sign in", style: theme.textTheme.headlineLarge),

            const SizedBox(height: 8),
            Row(
              children: [
                Text("or ", style: AppTextStyles.bodyText2),

                SizedBox(width: 1.w),

                TextButton(
                  onPressed: () {
                    context.push('/sign-up');
                  },
                  style: AppButtonStyles.textButton,
                  child: Text("Join lockedIn"),
                ),
              ],
            ),

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

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                print("Navigating to forgot password"); // Debug print
                context.push(
                  '/forgot-password',
                ); // Make sure this matches your route definition
              },
              style: AppButtonStyles.textButton,
              child: Text("Forgot password?"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: AppButtonStyles.elevatedButton,
              onPressed: () async {
                bool isLoggedIn = await ref
                    .read(loginViewModelProvider.notifier)
                    .login(
                      _emailController.text,
                      _passwordController.text,
                      context,
                    );
                if (isLoggedIn) {
                  context.go('/home');
                }
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
                    ref
                        .read(loginViewModelProvider.notifier)
                        .signInWithGoogle();
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
