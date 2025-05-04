import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/features/auth/widgets/primary_button.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({Key? key}) : super(key: key);

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
            'Verify your email',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to '),
                TextSpan(
                  text: viewModel.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(
                  text: '. Enter it below to verify your email address.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // OTP input field
          _buildOtpInput(context, viewModel),
          const SizedBox(height: 24),

          // Resend code option with timer
          Center(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
                children: [
                  const TextSpan(text: 'Didn\'t receive the code? '),
                  TextSpan(
                    text: 'Resend',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            // Resend OTP logic would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('New code sent to your email.'),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Email change option
          Center(
            child: TextButton(
              onPressed: () {
                viewModel.previousPage();
                viewModel.previousPage();
              },
              child: Text(
                'Change email address',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Verify button
          PrimaryButton(
            text: 'Verify',
            isEnabled: viewModel.isOtpValid(),
            onPressed: () {
              if (viewModel.isOtpValid()) {
                viewModel.verifyOtp(context);
              }
            },
            isLoading: viewModel.state == SignupState.loading,
          ),
          const SizedBox(height: 16),

          // Security info
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Your information is secure with us',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context, SignupViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 48,
          child: TextField(
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move to next field
                if (index < 5) {
                  FocusScope.of(context).nextFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }

                // Update OTP in viewModel
                final currentOtp = viewModel.otp;
                String newOtp = '';

                if (currentOtp.length <= index) {
                  newOtp = currentOtp + value;
                } else {
                  newOtp =
                      currentOtp.substring(0, index) +
                      value +
                      (index < currentOtp.length - 1
                          ? currentOtp.substring(index + 1)
                          : '');
                }

                viewModel.setOtp(newOtp);
              }
            },
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
