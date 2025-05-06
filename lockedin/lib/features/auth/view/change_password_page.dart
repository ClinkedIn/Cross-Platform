import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lockedin/features/auth/viewmodel/change_password_viewmodel.dart';
import 'package:lockedin/features/auth/view/Forget password/forgot_password_page.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

/// Navigation state provider
final navigationProvider = StateProvider<String>((ref) => '/');

/// Visibility state provider for password fields
final passwordVisibilityProvider =
    StateNotifierProvider<PasswordVisibilityNotifier, PasswordVisibilityState>(
      (ref) => PasswordVisibilityNotifier(),
    );

/// State provider for password-related form inputs and feedback messages
final passwordStateProvider =
    StateNotifierProvider<PasswordStateNotifier, PasswordState>(
      (ref) => PasswordStateNotifier(),
    );

/// Holds visibility states for all password fields and password guideline section
class PasswordVisibilityState {
  final bool isCurrentPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool showPasswordGuidelines;

  const PasswordVisibilityState({
    this.isCurrentPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.showPasswordGuidelines = false,
  });

  /// Returns a new copy of the state with updated fields
  PasswordVisibilityState copyWith({
    bool? isCurrentPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? showPasswordGuidelines,
  }) {
    return PasswordVisibilityState(
      isCurrentPasswordVisible:
          isCurrentPasswordVisible ?? this.isCurrentPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      showPasswordGuidelines:
          showPasswordGuidelines ?? this.showPasswordGuidelines,
    );
  }
}

/// Notifier for managing visibility toggles of password fields and password guidelines section
class PasswordVisibilityNotifier
    extends StateNotifier<PasswordVisibilityState> {
  PasswordVisibilityNotifier() : super(const PasswordVisibilityState());

  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(
      isCurrentPasswordVisible: !state.isCurrentPasswordVisible,
    );
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  void toggleGuidelines() {
    state = state.copyWith(
      showPasswordGuidelines: !state.showPasswordGuidelines,
    );
  }
}

/// State representing all password-related input fields and messages
class PasswordState {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool requireSignIn;
  final String statusMessage;
  final String errorMessage;
  final List<String> validations;

  const PasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.requireSignIn = true,
    this.statusMessage = '',
    this.errorMessage = '',
    this.validations = const [],
  });

  bool get isSaveEnabled =>
      currentPassword.isNotEmpty &&
      newPassword.length >= 8 &&
      newPassword == confirmPassword;

  PasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? requireSignIn,
    String? statusMessage,
    String? errorMessage,
    List<String>? validations,
  }) {
    return PasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      requireSignIn: requireSignIn ?? this.requireSignIn,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      validations: validations ?? this.validations,
    );
  }
}

/// StateNotifier that controls updates to the password fields and messages
class PasswordStateNotifier extends StateNotifier<PasswordState> {
  PasswordStateNotifier() : super(const PasswordState());

  void updateCurrentPassword(String value) {
    state = state.copyWith(currentPassword: value);
  }

  void updateNewPassword(String value) {
    state = state.copyWith(newPassword: value);
    validatePassword(value);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
    checkPasswordsMatch();
  }

  void toggleRequireSignIn() {
    state = state.copyWith(requireSignIn: !state.requireSignIn);
  }

  void setStatusMessage(String message) {
    state = state.copyWith(statusMessage: message, errorMessage: '');
  }

  void setErrorMessage(String message) {
    state = state.copyWith(errorMessage: message, statusMessage: '');
  }

  void clearMessages() {
    state = state.copyWith(statusMessage: '', errorMessage: '');
  }

  /// Validate password against requirements
  void validatePassword(String password) {
    final List<String> validations = [];

    if (password.length >= 8) {
      validations.add("✓ At least 8 characters");
    } else {
      validations.add("✗ At least 8 characters");
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      validations.add("✓ Contains uppercase letter");
    } else {
      validations.add("✗ Contains uppercase letter");
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      validations.add("✓ Contains lowercase letter");
    } else {
      validations.add("✗ Contains lowercase letter");
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      validations.add("✓ Contains number");
    } else {
      validations.add("✗ Contains number");
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      validations.add("✓ Contains special character");
    } else {
      validations.add("✗ Contains special character");
    }

    state = state.copyWith(validations: validations);
    checkPasswordsMatch();
  }

  /// Check if passwords match and update error message accordingly
  void checkPasswordsMatch() {
    if (state.confirmPassword.isNotEmpty &&
        state.newPassword != state.confirmPassword) {
      setErrorMessage("Passwords don't match");
    } else if (state.confirmPassword.isNotEmpty) {
      clearMessages();
    }
  }

  /// Full password validation
  bool isValidPassword() {
    // Check for password match first
    if (state.newPassword != state.confirmPassword) {
      setErrorMessage("Passwords don't match");
      return false;
    }

    // Complex password validation
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    );
    if (!regex.hasMatch(state.newPassword)) {
      setErrorMessage("Password doesn't meet all requirements");
      return false;
    }

    return true;
  }
}

/// UI page for changing the user's password
class ChangePasswordPage extends ConsumerWidget {
  const ChangePasswordPage({super.key});

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
        _showMessage(
          context,
          current.successMessage!,
          Icons.check_circle,
          Colors.green,
        );
      }

      if (current.errorMessage != null &&
          previous?.errorMessage != current.errorMessage) {
        _showMessage(
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
            onPressed: () {
              _showHelpDialog(context);
            },
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
              _buildSectionHeader(
                "Change Your Password",
                "Create a secure password to protect your account.",
              ),
              const SizedBox(height: 24),

              // Password Guidelines Section
              _buildPasswordGuidelinesSection(context, visibilityState, ref),
              const SizedBox(height: 24),

              // Password Entry Fields
              _buildPasswordFields(
                context,
                visibilityState,
                passwordState,
                ref,
              ),
              const SizedBox(height: 32),

              // Options Section
              _buildOptionsSection(context, passwordState, ref),
              const SizedBox(height: 40),

              // Action Buttons
              _buildActionButtons(context, passwordState, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headline1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.bodyText1),
      ],
    );
  }

  Widget _buildPasswordGuidelinesSection(
    BuildContext context,
    PasswordVisibilityState visibilityState,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: ref.read(passwordVisibilityProvider.notifier).toggleGuidelines,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Password Requirements",
                  style: AppTextStyles.headline2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  visibilityState.showPasswordGuidelines
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (visibilityState.showPasswordGuidelines)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(top: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "Strong Password Guidelines",
                        style: AppTextStyles.headline2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementItem(
                    "At least 8 characters long",
                    Icons.check_circle_outline,
                  ),
                  _buildRequirementItem(
                    "At least one uppercase letter (A-Z)",
                    Icons.check_circle_outline,
                  ),
                  _buildRequirementItem(
                    "At least one lowercase letter (a-z)",
                    Icons.check_circle_outline,
                  ),
                  _buildRequirementItem(
                    "At least one number (0-9)",
                    Icons.check_circle_outline,
                  ),
                  _buildRequirementItem(
                    "At least one special character (!@#\$%^&*)",
                    Icons.check_circle_outline,
                  ),
                  _buildRequirementItem(
                    "Avoid using personal information",
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodyText1)),
        ],
      ),
    );
  }

  Widget _buildPasswordFields(
    BuildContext context,
    PasswordVisibilityState visibilityState,
    PasswordState passwordState,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPasswordField(
          context,
          "Current Password",
          "Enter your current password",
          visibilityState.isCurrentPasswordVisible,
          () =>
              ref
                  .read(passwordVisibilityProvider.notifier)
                  .toggleCurrentPasswordVisibility(),
          (value) => ref
              .read(passwordStateProvider.notifier)
              .updateCurrentPassword(value),
        ),
        const SizedBox(height: 20),

        _buildPasswordField(
          context,
          "New Password",
          "Enter your new password",
          visibilityState.isNewPasswordVisible,
          () =>
              ref
                  .read(passwordVisibilityProvider.notifier)
                  .toggleNewPasswordVisibility(),
          (value) =>
              ref.read(passwordStateProvider.notifier).updateNewPassword(value),
        ),

        // Password validation indicators
        if (passwordState.newPassword.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  passwordState.validations.map((validation) {
                    final bool isValid = validation.startsWith("✓");
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        validation,
                        style: TextStyle(
                          fontSize: 12,
                          color: isValid ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

        const SizedBox(height: 20),

        _buildPasswordField(
          context,
          "Confirm Password",
          "Re-enter your new password",
          visibilityState.isConfirmPasswordVisible,
          () =>
              ref
                  .read(passwordVisibilityProvider.notifier)
                  .toggleConfirmPasswordVisibility(),
          (value) => ref
              .read(passwordStateProvider.notifier)
              .updateConfirmPassword(value),
        ),

        // Password match indicator
        if (passwordState.confirmPassword.isNotEmpty &&
            passwordState.newPassword.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Row(
              children: [
                Icon(
                  passwordState.newPassword == passwordState.confirmPassword
                      ? Icons.check_circle
                      : Icons.cancel,
                  color:
                      passwordState.newPassword == passwordState.confirmPassword
                          ? Colors.green
                          : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  passwordState.newPassword == passwordState.confirmPassword
                      ? "Passwords match"
                      : "Passwords don't match",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        passwordState.newPassword ==
                                passwordState.confirmPassword
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    String label,
    String hint,
    bool isVisible,
    VoidCallback toggleVisibility,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText2.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: !isVisible,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              onPressed: toggleVisibility,
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(
    BuildContext context,
    PasswordState passwordState,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sign out option
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: CheckboxListTile(
            value: passwordState.requireSignIn,
            title: Text(
              "Sign out from all devices",
              style: AppTextStyles.bodyText2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "All devices will be required to sign in with your new password",
              style: AppTextStyles.bodyText2.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            onChanged:
                (_) =>
                    ref
                        .read(passwordStateProvider.notifier)
                        .toggleRequireSignIn(),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Error message display
        if (passwordState.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passwordState.errorMessage,
                      style: AppTextStyles.bodyText1.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Status message display
        if (passwordState.statusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passwordState.statusMessage,
                      style: AppTextStyles.bodyText1.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PasswordState passwordState,
    WidgetRef ref,
  ) {
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
                  ? () async {
                    // Validate password
                    if (ref
                        .read(passwordStateProvider.notifier)
                        .isValidPassword()) {
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
                  : null,
          child:
              isLoading
                  ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
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
          child: Text(
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

  void _showMessage(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text("Password Help"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Why update your password?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Regularly updating your password helps protect your account from unauthorized access. We recommend changing your password every 3-6 months.",
                ),
                const SizedBox(height: 16),
                Text(
                  "Password tips:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text("• Use a unique password for each account"),
                Text("• Avoid using easily guessable information"),
                Text("• Consider using a password manager"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Got it"),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
