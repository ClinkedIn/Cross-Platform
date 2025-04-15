import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/auth/viewmodel/forget%20password%20viewmodels/new_password_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  final String resetToken;
  
  const NewPasswordScreen({Key? key, required this.resetToken}) : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _requireSignIn = true;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newPasswordViewModel = ref.read(newPasswordProvider(widget.resetToken).notifier);
    final newPasswordState = ref.watch(newPasswordProvider(widget.resetToken));

    // Show error message if there is one
    if (newPasswordState.hasError && !newPasswordState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${newPasswordState.error}'),
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
                        'Choose a new password',
                        style: theme.textTheme.headlineLarge?.copyWith(fontSize: 3.h),
                      ),
              
                      SizedBox(height: 1.5.h),
              
                      Text(
                        'To secure your account, choose a strong password you haven\'t used before and is at least 8 characters long.',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h),
                      ),
              
                      SizedBox(height: 3.h),
              
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
                        ),
                        validator: (value) => newPasswordViewModel.validatePassword(value),
                      ),
              
                      SizedBox(height: 2.h),
              
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Retype Password',
                          suffixIcon: IconButton(
                            icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                          ),
                          labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
                        ),
                        validator: (value) => newPasswordViewModel.validateConfirmPassword(
                          _passwordController.text,
                          value,
                        ),
                      ),
              
                      SizedBox(height: 2.h),
              
                      Row(
                        children: [
                          SizedBox(
                            width: 6.w,
                            child: Checkbox(
                              value: _requireSignIn,
                              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColors.primary;
                                }
                                return AppColors.background;
                              }),
                              checkColor: Colors.white,
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
                          onPressed: newPasswordState.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    FocusScope.of(context).unfocus(); // Hide keyboard
                                    
                                    await newPasswordViewModel.resetPassword(
                                      _passwordController.text,
                                      _requireSignIn,
                                    );
                                    
                                    // Check the state after operation
                                    final updatedState = ref.read(newPasswordProvider(widget.resetToken));
                                    
                                    if (!updatedState.hasError) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Password reset successful'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      
                                      // Navigate to login screen after successful password reset
                                      await Future.delayed(Duration(seconds: 2));
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => LoginPage()),
                                        (route) => false, // Remove all previous routes
                                      );
                                    }
                                  }
                                },
                          style: theme.elevatedButtonTheme.style,
                          child: newPasswordState.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Submit',
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