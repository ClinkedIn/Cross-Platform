import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/features/auth/widgets/primary_button.dart';
import 'package:lockedin/features/auth/widgets/signup_text_field.dart';

class NamePage extends StatelessWidget {
  const NamePage({Key? key}) : super(key: key);

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
            'Add your name',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let us know how to address you. Your name will appear on your profile and in your content.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // First name field
          SignupTextField(
            label: 'First name',
            hintText: 'Enter your first name',
            value: viewModel.firstName,
            onChanged: viewModel.setFirstName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Last name field
          SignupTextField(
            label: 'Last name',
            hintText: 'Enter your last name',
            value: viewModel.lastName,
            onChanged: viewModel.setLastName,
            textInputAction: TextInputAction.done,
          ),

          const Spacer(),

          // Next button
          PrimaryButton(
            text: 'Continue',
            isEnabled: viewModel.isNameFormValid(),
            onPressed: () {
              if (viewModel.isNameFormValid()) {
                viewModel.nextPage();
              }
            },
          ),
          const SizedBox(height: 16),

          // Terms and conditions text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
              children: [
                const TextSpan(
                  text: 'By clicking Continue, you agree to LinkedIn\'s ',
                ),
                TextSpan(
                  text: 'User Agreement',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ', '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ', and '),
                TextSpan(
                  text: 'Cookie Policy',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
