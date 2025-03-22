import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/view/forget%20Password/forgot_password_page.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/auth/view/forget%20Password/new_password_page.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class VerificationCodeScreen extends StatefulWidget {
  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Hide keyboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification successful"),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: LogoAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),
        
                Text(
                  'Enter the 6-digit code',
                  style: theme.textTheme.headlineLarge?.copyWith(fontSize: 3.h),
                ),
        
                SizedBox(height: 1.5.h),
        
                Text(
                  'Check *****@gmail.com for a verification code.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h),
                ),
        
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
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
        
                TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: '6-digit code',
                    counterText: "", // Hides character counter
                    labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the verification code";
                    } else if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                      return "Enter a valid 6-digit code";
                    }
                    return null;
                  },
                ),
        
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Resending code...")),
                    );
                  },
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
                    onPressed: _submitCode,
                    style: theme.elevatedButtonTheme.style,
                    child: Text(
                      'Submit',
                      style: theme.textTheme.labelLarge?.copyWith(fontSize: 2.2.h),
                    ),
                  ),
                ),
        
                SizedBox(height: 3.h),
        
                Text(
                  "If you don't see the email in your inbox, check your spam folder. If it's not there, the email address may not be confirmed, or it may not match an existing LinkedIn account.",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 1.6.h),
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
        ),
      ),
    );
  }
}
