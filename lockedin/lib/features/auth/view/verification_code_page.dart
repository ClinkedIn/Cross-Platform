import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/auth/view/new_password_page.dart';

class VerificationCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context); // Fetch current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Verification Code',
          style: theme.textTheme.headlineMedium,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),

            Text(
              'Enter the 6-digit code',
              style: theme.textTheme.headlineLarge,
            ),

            SizedBox(height: 10),

            Text(
              'Check *****@gmail.com for a verification code.',
              style: theme.textTheme.bodyMedium,
            ),

            TextButton(
              onPressed: () {},
              style: theme.textButtonTheme.style,
              child: Text(
                'Change',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                labelText: '6-digit code',
              )
            ),

            TextButton(
              onPressed: () {},
              style: theme.textButtonTheme.style,
              child: Text(
                'Resend code',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

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
                  style: theme.textTheme.labelLarge
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              "If you don't see the email in your inbox, check your spam folder. If it's not there, the email address may not be confirmed, or it may not match an existing LinkedIn account.",
              style: theme.textTheme.bodySmall,
            ),

            TextButton(
              onPressed: () {},
              style: theme.textButtonTheme.style,
              child: Text(
                "Can't access this email?",
                style: theme.textTheme.labelLarge?.copyWith(
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
