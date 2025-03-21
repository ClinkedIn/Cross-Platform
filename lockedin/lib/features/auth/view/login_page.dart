import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/view/forgot_password_page.dart';
import 'package:lockedin/features/auth/view/signup/sign_up_view.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 5.h,
        ), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Locked ",
                  style: AppTextStyles.headline1.copyWith(
                    color: AppColors.primary,
                    fontSize: 3.h, // Responsive font size
                  ),
                ),
                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
                  height: 4.h, // Responsive height
                ),
              ],
            ),
            SizedBox(height: 5.h), // Responsive spacing
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
                    Navigator.push(
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
                fillColor: isDarkMode ? AppColors.black : AppColors.white,
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
                fillColor: isDarkMode ? AppColors.black : AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),
            SizedBox(height: 3.h),
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
                  fontSize: 1.8.h,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              style: AppButtonStyles.elevatedButton,
              onPressed: () {},
              child: Text(
                "Sign in",
                style: TextStyle(fontSize: 2.h), // Responsive text
              ),
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
