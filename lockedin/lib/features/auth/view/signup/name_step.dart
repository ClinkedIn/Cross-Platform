import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';

class NameStep extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final SignupViewModel notifier;
  final VoidCallback onNextStep; // ✅ Callback to move to the next step

  const NameStep({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.notifier,
    required this.onNextStep, // ✅ Receive the callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add your name', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 20),
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            labelText: 'First name*',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            labelText: 'Last name*',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                firstNameController.text.isNotEmpty &&
                        lastNameController.text.isNotEmpty
                    ? () {
                      notifier.setFirstName(firstNameController.text);
                      notifier.setLastName(lastNameController.text);
                      onNextStep(); // ✅ Call the function to go to the next step
                    }
                    : null,
            style: AppButtonStyles.elevatedButton,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
