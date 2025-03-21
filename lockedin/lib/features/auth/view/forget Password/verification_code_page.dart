import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/auth/view/forget%20Password/new_password_page.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class VerificationCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: LogoAppbar(),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h), // Responsive spacing

            Text(
              'Enter the 6-digit code',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 3.h), // Responsive text
            ),

            SizedBox(height: 1.5.h),

            Text(
              'Check *****@gmail.com for a verification code.',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h), // Responsive text
            ),

            TextButton(
              onPressed: () {},
              style: theme.textButtonTheme.style,
              child: Text(
                'Change',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 2.h,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 2.h),

            TextField(
              decoration: InputDecoration(
                labelText: '6-digit code',
                labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
              ),
            ),

            TextButton(
              onPressed: () {},
              style: theme.textButtonTheme.style,
              child: Text(
                'Resend code',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 2.h,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 2.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewPasswordScreen(),
                    ),
                  );
                },
                style: theme.elevatedButtonTheme.style,
                child: Text(
                  'Submit',
                  style: theme.textTheme.labelLarge?.copyWith(fontSize: 2.2.h), // Responsive text
                ),
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              "If you don't see the email in your inbox, check your spam folder. If it's not there, the email address may not be confirmed, or it may not match an existing LinkedIn account.",
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 1.6.h), // Responsive text
            ),

            TextButton(
              onPressed: () {},
              style: theme.textButtonTheme.style,
              child: Text(
                "Can't access this email?",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 2.h,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
