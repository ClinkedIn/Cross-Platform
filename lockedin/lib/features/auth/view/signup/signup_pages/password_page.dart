import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/features/auth/widgets/primary_button.dart';
import 'package:lockedin/features/auth/widgets/signup_text_field.dart';
import 'package:provider/provider.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignupViewModel>(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your password',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a secure password for your account.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // Password field
          SignupTextField(
            label: 'Password',
            hintText: 'Create a password',
            value: viewModel.password,
            onChanged: viewModel.setPassword,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),

          // Password requirements
          _buildPasswordRequirement(
            'At least 8 characters',
            viewModel.password.length >= 8,
            theme,
          ),
          _buildPasswordRequirement(
            'At least one uppercase letter',
            viewModel.password.contains(RegExp(r'[A-Z]')),
            theme,
          ),
          _buildPasswordRequirement(
            'At least one lowercase letter',
            viewModel.password.contains(RegExp(r'[a-z]')),
            theme,
          ),
          _buildPasswordRequirement(
            'At least one number',
            viewModel.password.contains(RegExp(r'[0-9]')),
            theme,
          ),
          _buildPasswordRequirement(
            'At least one special character (!@#\$%^&*)',
            viewModel.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
            theme,
          ),

          const SizedBox(height: 16),

          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: viewModel.rememberMe,
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setRememberMe(value);
                  }
                },
                activeColor: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stay signed in',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Sign up button
          PrimaryButton(
            text: 'Sign up',
            isEnabled: viewModel.isPasswordValid(),
            onPressed: () {
              if (viewModel.isPasswordValid()) {
                // Call API to register user then navigate to OTP page
                viewModel.signUp(context);
              }
            },
            isLoading: viewModel.state == SignupState.loading,
          ),
          const SizedBox(height: 16),

          // Security info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your password is securely encrypted and never shared.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? theme.primaryColor : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMet ? theme.primaryColor : Colors.black54,
              fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
