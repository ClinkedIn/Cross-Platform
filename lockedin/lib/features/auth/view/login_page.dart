import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/auth/viewmodel/login_in_viewmodel.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final loginState = ref.watch(loginViewModelProvider);
    final loginVM = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      appBar: LogoAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 42),

              Text("Sign in", style: theme.textTheme.headlineLarge),

              const SizedBox(height: 8),
              Row(
                children: [
                  Text("or ", style: AppTextStyles.bodyText2),
                  SizedBox(width: 1.w),
                  TextButton(
                    onPressed: () {
                      context.push('/sign-up');
                    },
                    style: AppButtonStyles.textButton,
                    child: Text("Join lockedIn"),
                  ),
                ],
              ),

              // Show error messages when there's an error
              if (loginState is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loginVM.getErrorMessage(),
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Email field with validation
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email or Phone",
                  filled: true,
                  fillColor: isDarkMode ? AppColors.black : AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              SizedBox(height: 2.h),

              // Password field with validation
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: isDarkMode ? AppColors.black : AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  context.push('/forgot-password');
                },
                style: AppButtonStyles.textButton,
                child: Text("Forgot password?"),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: AppButtonStyles.elevatedButton,
                onPressed:
                    loginState is AsyncLoading
                        ? null // Disable button when loading
                        : () async {
                          // First validate the form
                          if (_formKey.currentState!.validate()) {
                            bool isLoggedIn = await loginVM.login(
                              _emailController.text,
                              _passwordController.text,
                              context,
                            );
                           if (isLoggedIn && context.mounted) {
                              ref
                                  .read(profileViewModelProvider)
                                  .fetchAllProfileData();
                              context.go('/');

                            }

                          }
                        },
                child:
                    loginState is AsyncLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text("Sign in"),
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider()),
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
                  const SizedBox(height: 12),
                  AppButtonStyles.socialLoginButton(
                    text: "Sign in with Google",
                    icon: Icons.g_mobiledata,
                    onPressed: () {
                      ref
                          .read(loginViewModelProvider.notifier)
                          .signInWithGoogle();

                          context.go('/');

                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
