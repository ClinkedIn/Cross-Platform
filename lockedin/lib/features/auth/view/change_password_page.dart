import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lockedin/features/auth/viewmodel/change_password_viewmodel.dart';

import 'package:lockedin/features/auth/view/Forget password/forgot_password_page.dart';

//import 'package:lockedin/shared/theme/app_theme.dart';

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

  PasswordVisibilityState({
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
  PasswordVisibilityNotifier() : super(PasswordVisibilityState());

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

  PasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.requireSignIn = true,
    this.statusMessage = '',
    this.errorMessage = '',
  });

  bool get isSaveEnabled =>
      newPassword.length >= 8 && newPassword == confirmPassword;

  PasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? requireSignIn,
    String? statusMessage,
    String? errorMessage,
  }) {
    return PasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      requireSignIn: requireSignIn ?? this.requireSignIn,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier that controls updates to the password fields and messages
class PasswordStateNotifier extends StateNotifier<PasswordState> {
  PasswordStateNotifier() : super(PasswordState());

  void updatePasswords(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) {
    state = state.copyWith(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  void toggleRequireSignIn() {
    state = state.copyWith(requireSignIn: !state.requireSignIn);
  }

  void setStatusMessage(String message) {
    state = state.copyWith(statusMessage: message);
  }

  void setErrorMessage(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// Basic password validation using regex
  void isValidPassword(String password) {
    setErrorMessage("");
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!regex.hasMatch(password)) setErrorMessage("❌ Invalid password format");
    return;
  }
}

/// UI page for changing the user's password
class ChangePasswordPage extends ConsumerWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibilityState = ref.watch(passwordVisibilityProvider);
    final passwordState = ref.watch(passwordStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: AppTextStyles.headline1),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a new password that is at least 8 characters long.",
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed:
                  ref
                      .read(passwordVisibilityProvider.notifier)
                      .toggleGuidelines,
              icon: const Icon(Icons.shield, color: Colors.blue),
              label: Text(
                "What makes a strong password?",
                style: AppTextStyles.headline2,
              ),
            ),
            if (visibilityState.showPasswordGuidelines)
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose a strong password to\nprotect your account\n",
                        style: AppTextStyles.headline2,
                      ),
                      Text(
                        "• It should be a mix of letters, numbers, and special characters",
                        style: AppTextStyles.bodyText1,
                      ),
                      Text(
                        "• It should be at least 8 characters long",
                        style: AppTextStyles.bodyText1,
                      ),
                      Text(
                        "• It should not contain your name, phone number or email address",
                        style: AppTextStyles.bodyText1,
                      ),
                    ],
                  ),
                ),
              ),

            _buildPasswordField(
              "Type your current password",
              visibilityState.isCurrentPasswordVisible,
              ref
                  .read(passwordVisibilityProvider.notifier)
                  .toggleCurrentPasswordVisibility,
              (value) => ref
                  .read(passwordStateProvider.notifier)
                  .updatePasswords(
                    value,
                    passwordState.newPassword,
                    passwordState.confirmPassword,
                  ),
            ),
            _buildPasswordField(
              "Type your new password",
              visibilityState.isNewPasswordVisible,
              ref
                  .read(passwordVisibilityProvider.notifier)
                  .toggleNewPasswordVisibility,
              (value) => ref
                  .read(passwordStateProvider.notifier)
                  .updatePasswords(
                    passwordState.currentPassword,
                    value,
                    passwordState.confirmPassword,
                  ),
            ),
            _buildPasswordField(
              "Retype your new password",
              visibilityState.isConfirmPasswordVisible,
              ref
                  .read(passwordVisibilityProvider.notifier)
                  .toggleConfirmPasswordVisibility,
              (value) => ref
                  .read(passwordStateProvider.notifier)
                  .updatePasswords(
                    passwordState.currentPassword,
                    passwordState.newPassword,
                    value,
                  ),
            ),

            Row(
              children: [
                Checkbox(
                  value: passwordState.requireSignIn,
                  onChanged:
                      (_) =>
                          ref
                              .read(passwordStateProvider.notifier)
                              .toggleRequireSignIn(),
                ),
                Text(
                  "Require all devices to sign in with new password",
                  style: AppTextStyles.bodyText2,
                ),
              ],
            ),

            ElevatedButton(
              style: AppButtonStyles.elevatedButton,
              onPressed:
                  passwordState.isSaveEnabled
                      ? () {
                        ref
                            .read(passwordStateProvider.notifier)
                            .isValidPassword(passwordState.newPassword);
                        ref
                            .read(changePasswordViewModelProvider.notifier)
                            .changePassword(
                              passwordState.newPassword,
                              passwordState.currentPassword,
                            );
                      }
                      : null,
              child: const Text("Save Password"),
            ),

            // Status message display
            if (passwordState.statusMessage.isNotEmpty &&
                passwordState.errorMessage.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  passwordState.statusMessage,
                  style: AppTextStyles.bodyText1.copyWith(
                    color:
                        passwordState.statusMessage.contains("✅")
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            // Error message display
            if (passwordState.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  passwordState.errorMessage,
                  style: AppTextStyles.bodyText1.copyWith(color: Colors.red),
                ),
              ),

            OutlinedButton(
              style: AppButtonStyles.outlinedButton,
              onPressed: () {
                ref.read(navigationProvider.notifier).state = '/chats';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text("Forgot Password"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    bool isVisible,
    VoidCallback toggleVisibility, [
    Function(String)? onChanged,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyText2),
        TextField(
          obscureText: !isVisible,
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: toggleVisibility,
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
