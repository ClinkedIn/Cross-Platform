import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
import 'package:lockedin/features/auth/view/sign_up_view.dart';
import 'package:lockedin/features/auth/viewmodel/login_in_viewmodel.dart';
import 'package:lockedin/main.dart';
import 'package:lockedin/features/auth/view/forgot_password_page.dart';
import 'package:lockedin/features/auth/view/signup/sign_up_view.dart';
//import 'package:google_fonts/google_fonts.dart';

import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
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
            Text("Sign in", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("or ", style: AppTextStyles.bodyText2),
                TextButton(
                  onPressed: () {

                    Navigator.pushReplacement(
                    Navigator.push(

                      context,
                      MaterialPageRoute(builder: (context) => SignUpView()),
                    );
                  },
                  child: Text(
                    "Join LockedIn",

                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
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
            const SizedBox(height: 12),
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
              onPressed: () {},
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
            const SizedBox(height: 20),
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
