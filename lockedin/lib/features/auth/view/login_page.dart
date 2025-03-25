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
    final loginState = ref.watch(loginViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(

      appBar: LogoAppbar(),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 5.h,
        ), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Sign in",
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 3.5.h),
            ),

            SizedBox(height: 1.h),

            Row(
              children: [
                Text(
                  "or ",
                  style: AppTextStyles.bodyText2.copyWith(fontSize: 1.8.h),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpView()),
                    );
                  },
                  child: Text(
                    "Join LockedIn",
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primary,
                      fontSize: 1.8.h,
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

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
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

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            loginState.when(
              data:
                  (_) => ElevatedButton(
                    style: AppButtonStyles.elevatedButton,
                    onPressed: () async {
                      await ref
                          .read(loginViewModelProvider.notifier)
                          .login(
                            _emailController.text,
                            _passwordController.text,
                          );

                      // If successful, navigate to Home Page
                      if (ref.read(loginViewModelProvider).hasValue) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      }
                    },
                    child: const Text("Sign in"),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Column(
                    children: [
                      Text(
                        "Error: $error",
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(loginViewModelProvider.notifier)
                              .login(
                                _emailController.text,
                                _passwordController.text,
                              );
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text("Forgot password?", style: AppTextStyles.buttonText),
            ),

            SizedBox(height: 3.h),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ), // Responsive padding
                  child: Text("or", style: TextStyle(fontSize: 1.8.h)),
                ),
                const Expanded(child: Divider()),
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
                SizedBox(height: 2.h),
                AppButtonStyles.socialLoginButton(
                  text: "Sign in with Google",
                  icon: Icons.g_mobiledata,
                  onPressed: () {},
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
