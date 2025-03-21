import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/forget%20Password/verification_code_page.dart';
import 'package:lockedin/features/auth/viewmodel/forgot_password_viewmodel.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController emailOrPhoneController = TextEditingController();


  //Check if the email is valid
  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");  
    return emailRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordViewModel = ref.read(forgotPasswordProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: LogoAppbar(),

      // Wrap UI in SingleChildScrollView to avoid overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Form(
            key: _formKey, // Wrap UI in Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),

                TextFormField(
                  controller: emailOrPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone',
                    labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    } else if (!_isValidEmail(value)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 2.h),

                Text(
                  "We'll send a verification code to this email or phone number if it matches an existing LinkedIn account.",
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h),
                ),

                SizedBox(height: 4.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: forgotPasswordState.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus(); // Hide keyboard

                              await forgotPasswordViewModel.sendForgotPasswordRequest(
                                emailOrPhoneController.text,
                              );

                              // Get the latest state after API call
                              final updatedState = ref.read(forgotPasswordProvider);

                              if (updatedState.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: ${updatedState.error}"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Verification code sent successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                await Future.delayed(Duration(seconds: 1)); // Ensure message is displayed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerificationCodeScreen(),
                                  ),
                                );
                              }
                            }
                          },
                    style: theme.elevatedButtonTheme.style,
                    child: forgotPasswordState.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Next',
                            style: theme.textTheme.labelLarge?.copyWith(fontSize: 2.2.h),
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
