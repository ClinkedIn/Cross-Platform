import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/providers/auth_providers.dart';
import 'package:lockedin/features/auth/services/change_password_service.dart';
import 'package:lockedin/features/auth/state/password_state.dart';
import 'package:lockedin/features/auth/state/password_visibility_state.dart';
import 'package:lockedin/features/auth/utils/ui_helpers.dart';
import 'package:lockedin/features/auth/widgets/action_buttons.dart';
import 'package:lockedin/features/auth/widgets/password_field.dart';
import 'package:lockedin/features/auth/widgets/password_guidelines.dart';
import 'package:lockedin/features/auth/widgets/password_options.dart';
import 'package:lockedin/features/auth/widgets/section_header.dart';
import 'package:lockedin/features/auth/widgets/validation_indicators.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class ChangePasswordState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });
}

class ChangePasswordViewModel extends StateNotifier<ChangePasswordState> {
  ChangePasswordViewModel() : super(ChangePasswordState());

  Future<bool> changePassword(
    String newPassword,
    String currentPassword,
  ) async {
    state = ChangePasswordState(isLoading: true);

    try {
      final response = await ChangePasswordService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.statusCode == 200) {
        state = ChangePasswordState(
          successMessage: 'Password updated successfully',
        );
        return true;
      } else {
        state = ChangePasswordState(errorMessage: 'Failed to update password');
        return false;
      }
    } catch (e) {
      state = ChangePasswordState(errorMessage: e.toString());
      return false;
    }
  }
}

final changePasswordViewModelProvider =
    StateNotifierProvider<ChangePasswordViewModel, ChangePasswordState>((ref) {
      return ChangePasswordViewModel();
    });

/// UI page for changing the user's password
class ChangePasswordPage extends ConsumerWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibilityState = ref.watch(passwordVisibilityProvider);
    final passwordState = ref.watch(passwordStateProvider);
    final theme = Theme.of(context);

    // Watch for changes in the password viewmodel state
    ref.listen<ChangePasswordState>(changePasswordViewModelProvider, (
      previous,
      current,
    ) {
      if (current.successMessage != null &&
          previous?.successMessage != current.successMessage) {
        UIHelpers.showMessage(
          context,
          current.successMessage!,
          Icons.check_circle,
          Colors.green,
        );
      }

      if (current.errorMessage != null &&
          previous?.errorMessage != current.errorMessage) {
        UIHelpers.showMessage(
          context,
          current.errorMessage!,
          Icons.error_outline,
          Colors.red,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: AppTextStyles.headline1),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => UIHelpers.showHelpDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.1), Colors.transparent],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: "Change Your Password",
                subtitle: "Create a secure password to protect your account.",
              ),
              const SizedBox(height: 24),

              // Password Guidelines Section
              const PasswordGuidelinesSection(),
              const SizedBox(height: 24),

              // Password Fields Section
              _buildPasswordFieldsSection(
                context,
                visibilityState,
                passwordState,
                ref,
              ),
              const SizedBox(height: 32),

              // Options Section
              const PasswordOptionsSection(),
              const SizedBox(height: 40),

              // Action Buttons
              const ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFieldsSection(
    BuildContext context,
    PasswordVisibilityState visibilityState,
    PasswordState passwordState,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordField(
          label: "Current Password",
          hint: "Enter your current password",
          isVisible: visibilityState.isCurrentPasswordVisible,
          toggleVisibility:
              () =>
                  ref
                      .read(passwordVisibilityProvider.notifier)
                      .toggleCurrentPasswordVisibility(),
          onChanged:
              (value) => ref
                  .read(passwordStateProvider.notifier)
                  .updateCurrentPassword(value),
        ),
        const SizedBox(height: 20),

        PasswordField(
          label: "New Password",
          hint: "Enter your new password",
          isVisible: visibilityState.isNewPasswordVisible,
          toggleVisibility:
              () =>
                  ref
                      .read(passwordVisibilityProvider.notifier)
                      .toggleNewPasswordVisibility(),
          onChanged:
              (value) => ref
                  .read(passwordStateProvider.notifier)
                  .updateNewPassword(value),
        ),

        // Password validation indicators
        if (passwordState.newPassword.isNotEmpty)
          PasswordValidationIndicators(validations: passwordState.validations),

        const SizedBox(height: 20),

        PasswordField(
          label: "Confirm Password",
          hint: "Re-enter your new password",
          isVisible: visibilityState.isConfirmPasswordVisible,
          toggleVisibility:
              () =>
                  ref
                      .read(passwordVisibilityProvider.notifier)
                      .toggleConfirmPasswordVisibility(),
          onChanged:
              (value) => ref
                  .read(passwordStateProvider.notifier)
                  .updateConfirmPassword(value),
        ),

        // Password match indicator
        if (passwordState.confirmPassword.isNotEmpty &&
            passwordState.newPassword.isNotEmpty)
          PasswordMatchIndicator(
            newPassword: passwordState.newPassword,
            confirmPassword: passwordState.confirmPassword,
          ),
      ],
    );
  }
}
