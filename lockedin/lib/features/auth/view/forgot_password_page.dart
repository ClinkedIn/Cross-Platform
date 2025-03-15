import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/view/verification_code_page.dart';


class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Apply theme background
      appBar: AppBar(
        title: Text(
          'Forgot password',
          style: theme.textTheme.headlineMedium, // Apply theme-based text styling
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
              'Forgot password',
              style: theme.textTheme.headlineLarge, // Theme applied
            ),

            SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: 'Email or Phone',
              )
            ),

            SizedBox(height: 15),

            Text(
              "We'll send a verification code to this email or phone number if it matches an existing LinkedIn account.",
              style: theme.textTheme.bodyMedium,
            ),

            SizedBox(height: 30),

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
                  style: theme.textTheme.labelLarge
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
