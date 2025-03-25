import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';

class EmailStep extends StatefulWidget {
  final TextEditingController emailController;
  final SignupViewModel notifier;
  final VoidCallback onNextStep;
  final VoidCallback onBack;

  const EmailStep({
    Key? key,
    required this.emailController,
    required this.notifier,
    required this.onNextStep,
    required this.onBack,
  }) : super(key: key);

  @override
  _EmailStepState createState() => _EmailStepState();
}

class _EmailStepState extends State<EmailStep> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 200, end: 0), // Move from right to left
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(value, 0),
              child: TextField(
                controller: widget.emailController,
                decoration: InputDecoration(
                  labelText: 'Email or Phone*',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: errorText,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        // Continue Button Animation (Moves from Bottom to Up)
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 50, end: 0), // Start from below
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, value), // Move vertically from bottom to up
              child: _buildContinueButton(),
            );
          },
        ),

        _buildBackButton(),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            widget.emailController.text.isNotEmpty
                ? () {
                  final validationMessage = widget.notifier
                      .validateEmailOrPhone(widget.emailController.text);

                  if (validationMessage != null) {
                    setState(() {
                      errorText = validationMessage;
                    });
                  } else {
                    setState(() {
                      errorText = null;
                    });

                    widget.notifier.setEmail(widget.emailController.text);
                    widget.onNextStep(); // ✅ Move to the next step
                  }
                }
                : null,
        style: AppButtonStyles.elevatedButton,
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
