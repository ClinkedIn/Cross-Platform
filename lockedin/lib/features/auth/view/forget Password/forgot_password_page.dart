import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/view/forget%20Password/verification_code_page.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Apply theme background
      appBar: LogoAppbar(),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h), // Responsive spacing

            TextField(
              decoration: InputDecoration(
                labelText: 'Email or Phone',
                labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h), // Responsive text
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              "We'll send a verification code to this email or phone number if it matches an existing LinkedIn account.",
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h), // Responsive text
            ),

            SizedBox(height: 4.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificationCodeScreen(),
                    ),
                  );
                },
                style: theme.elevatedButtonTheme.style, // Use theme styling
                child: Text(
                  'Next',
                  style: theme.textTheme.labelLarge?.copyWith(fontSize: 2.2.h), // Responsive text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
