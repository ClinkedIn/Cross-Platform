import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class NewPasswordScreen extends StatefulWidget {
  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _requireSignIn = true;

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
              'Choose a new password',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 3.h),
            ),

            SizedBox(height: 1.5.h),

            Text(
              'To secure your account, choose a strong password you haven’t used before and is at least 8 characters long.',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h),
            ),

            SizedBox(height: 3.h),

            TextField(
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: "New password",
                labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 2.h),

            TextField(
              obscureText: !_confirmPasswordVisible,
              decoration: InputDecoration(
                labelText: "Retype new password",
                labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 2.h),

            Row(
              children: [
                SizedBox(
                  width: 6.w, // Responsive checkbox width
                  child: Checkbox(
                    value: _requireSignIn,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary; // Blue when checked
                      }
                      return AppColors.background; // Default background color
                    }),
                    checkColor: Colors.white, // Checkmark color
                    onChanged: (value) {
                      setState(() {
                        _requireSignIn = value!;
                      });
                    },
                  ),
                ),
                
                SizedBox(width: 2.w),

                Expanded(
                  child: Text(
                    "Require all devices to sign in with new password",
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 1.8.h),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Submit',
                  style: theme.textTheme.labelLarge?.copyWith(fontSize: 2.2.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
