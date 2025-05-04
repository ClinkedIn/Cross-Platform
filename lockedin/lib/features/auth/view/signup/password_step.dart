import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/auth/state/sign_up_state.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';

class PasswordStep extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final SignupState viewModel;
  final SignupViewModel notifier;
  final VoidCallback onBack;

  const PasswordStep({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.viewModel,
    required this.notifier,
    required this.onBack,
  }) : super(key: key);

  @override
  _PasswordStepState createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  bool _isPasswordVisible = false;
  String? emailErrorText;
  String? passwordErrorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.emailController,
          decoration: InputDecoration(
            labelText: 'Email or Phone*',
            filled: true,
            fillColor: isDarkMode ? AppColors.black : AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: emailErrorText,
          ),
          onChanged: (value) {
            final validationMessage = widget.notifier.validateEmailOrPhone(
              value,
            );
            setState(() {
              emailErrorText = validationMessage;
            });
          },
        ),
        const SizedBox(height: 15),

        TweenAnimationBuilder(
          tween: Tween<double>(begin: 200, end: 0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(value, 0),
              child: TextField(
                controller: widget.passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password*',
                  filled: true,
                  fillColor: isDarkMode ? AppColors.black : AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  errorText: passwordErrorText,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),
        Text(
          "Password must be 6+ characters",
          style: AppTextStyles.bodyText1.copyWith(color: AppColors.gray),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Checkbox(
              value: widget.viewModel.rememberMe,
              activeColor: AppColors.primary, // Only applies when checked
              fillColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.primary; // Use primary color when checked
                }
                return Colors.transparent; // Transparent when unchecked
              }),
              checkColor:
                  Colors.white, // Ensures the checkmark is visible when checked
              onChanged: (bool? value) {
                if (value != null) {
                  widget.notifier.setRememberMe(value);
                }
              },
            ),

            Text("Remember me", style: theme.textTheme.bodyLarge),
          ],
        ),

        const SizedBox(height: 30),

        _buildContinueButton(
          widget.passwordController.text.length >= 6,
          () async {
            final emailValidation = widget.notifier.validateEmailOrPhone(
              widget.emailController.text,
            );
            if (emailValidation != null) {
              setState(() => emailErrorText = emailValidation);
              return;
            }

            setState(() => emailErrorText = null);

            if (widget.passwordController.text.length < 6) {
              setState(
                () =>
                    passwordErrorText =
                        "Password must be at least 6 characters",
              );
              return;
            } else {
              setState(() => passwordErrorText = null);
            }

            widget.notifier.setPassword(widget.passwordController.text);
            final String signupMessage = await widget.notifier.submitForm();
            print("Signup message: $signupMessage");
            print("Success: ${widget.viewModel.success}");
            print("Is loading: ${widget.viewModel.isLoading}");
            if (context.mounted && widget.viewModel.success) {
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(signupMessage),
                  backgroundColor: AppColors.green,
                ),
              );
            } else if (!widget.viewModel.success) {
              print("Error: $signupMessage");
              context.go('/signup');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(signupMessage),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
        ),

        _buildBackButton(),
      ],
    );
  }

  Widget _buildContinueButton(bool isEnabled, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: const Text('Continue'),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: widget.onBack,
      child: const Text(
        'Back',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
