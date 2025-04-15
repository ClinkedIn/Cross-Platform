import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/forget%20Password/forgot_password_page.dart';
import 'package:lockedin/features/auth/view/forget%20Password/new_password_page.dart';
import 'package:lockedin/features/auth/viewmodel/forget%20password%20viewmodels/verification_code_viewmodel.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class VerificationCodeScreen extends ConsumerStatefulWidget {
  final String? emailOrPhone;

  const VerificationCodeScreen({Key? key, this.emailOrPhone}) : super(key: key);

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends ConsumerState<VerificationCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set email or phone in the ViewModel if provided
    if (widget.emailOrPhone != null && widget.emailOrPhone!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(verificationCodeProvider.notifier).setEmailOrPhone(widget.emailOrPhone!);
      });
    }
  }

  Future<void> _submitCode() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Hide keyboard
      
      final success = await ref.read(verificationCodeProvider.notifier)
          .verifyCode(codeController.text);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Verification successful"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Get the token to pass to the next screen
        final token = ref.read(verificationCodeProvider).token;
        
        await Future.delayed(Duration(seconds: 1));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(resetToken: token),
          ),
        );
      } else {
        // Error message is handled by the SnackBar in build method when state changes
      }
    }
  }

  Future<void> _resendCode() async {
    final success = await ref.read(verificationCodeProvider.notifier).resendCode();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification code resent successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
    // Error message is handled by the SnackBar in build method when state changes
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verificationState = ref.watch(verificationCodeProvider);

    // Show error message if there is one
    if (verificationState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${verificationState.error}"),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

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
        
                Row(
                  children: [
                    Text(
                      'Check your email for a verification code.',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h),
                    ),

                    SizedBox(width: 1.w),
                            
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      style: AppButtonStyles.textButton,
                      child: Text('Change'),
                    ),
                  ],
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
                  validator: (value) => ref.read(verificationCodeProvider.notifier).validateCode(value),
                ),
        
                TextButton(
                  onPressed: verificationState.isLoading ? null : _resendCode,
                  style: AppButtonStyles.textButton,
                  child: Text('Resend code'),
                ),
        
                SizedBox(height: 2.h),
        
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: verificationState.isLoading ? null : _submitCode,
                    style: theme.elevatedButtonTheme.style,
                    child: verificationState.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
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
                  style: AppButtonStyles.textButton,
                  child: Text("Can't access this email?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}