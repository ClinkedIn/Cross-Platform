import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/features/auth/widgets/primary_button.dart';
import 'package:lockedin/features/auth/widgets/signup_text_field.dart';

class EmailPage extends StatelessWidget {
  const EmailPage({Key? key}) : super(key: key);

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
            'Add your email',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll send a verification code to this email. Please ensure it\'s correct.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // Email field
          SignupTextField(
            label: 'Email',
            hintText: 'Enter your email address',
            value: viewModel.email,
            onChanged: viewModel.setEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),

          // Email format helper text
          Text(
            'Please use a valid email format (example@domain.com)',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),

          const Spacer(),

          // Next button
          PrimaryButton(
            text: 'Continue',
            isEnabled: viewModel.isEmailValid(),
            onPressed: () {
              if (viewModel.isEmailValid()) {
                viewModel.nextPage();
              }
            },
          ),
          const SizedBox(height: 16),

          // Privacy text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
              children: [
                const TextSpan(
                  text:
                      'We\'ll use your email address to share updates and help secure your account. See our ',
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' for more details.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
