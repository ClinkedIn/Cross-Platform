import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/providers/auth_providers.dart';
import 'package:lockedin/features/auth/state/password_state.dart';
import 'package:lockedin/features/auth/view/Forget%20password/forgot_password_page.dart';
import 'package:lockedin/features/auth/viewmodel/change_password_viewmodel.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordState = ref.watch(passwordStateProvider);
    final isLoading = ref.watch(changePasswordViewModelProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Save button
        ElevatedButton(
          style: AppButtonStyles.elevatedButton.copyWith(
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          onPressed:
              passwordState.isSaveEnabled && !isLoading
                  ? () => _handlePasswordUpdate(context, ref, passwordState)
                  : null,
          child:
              isLoading
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text(
                    "Update Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
        ),

        const SizedBox(height: 16),

        // Forgot Password button
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            ref.read(navigationProvider.notifier).state = '/forgot-password';
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            );
          },
          child: const Text(
            "Forgot your password?",
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePasswordUpdate(
    BuildContext context,
    WidgetRef ref,
    PasswordState passwordState,
  ) async {
    // Validate password
    if (ref.read(passwordStateProvider.notifier).isValidPassword()) {
      // Attempt to change password
      final success = await ref
          .read(changePasswordViewModelProvider.notifier)
          .changePassword(
            passwordState.newPassword,
            passwordState.currentPassword,
          );

      if (success && context.mounted) {
        // Show success message and navigate back after delay
        ref
            .read(passwordStateProvider.notifier)
            .setStatusMessage("Password updated successfully");

        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) Navigator.pop(context);
        });
      }
    }
  }
}
