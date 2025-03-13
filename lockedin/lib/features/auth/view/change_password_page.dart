import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
//import 'package:lockedin/shared/theme/colors.dart';

final passwordVisibilityProvider = StateNotifierProvider<PasswordVisibilityNotifier, PasswordVisibilityState>(
  (ref) => PasswordVisibilityNotifier(),
);

final passwordStateProvider = StateNotifierProvider<PasswordStateNotifier, PasswordState>(
  (ref) => PasswordStateNotifier(),
);

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

  PasswordVisibilityState copyWith({
    bool? isCurrentPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? showPasswordGuidelines,
  }) {
    return PasswordVisibilityState(
      isCurrentPasswordVisible: isCurrentPasswordVisible ?? this.isCurrentPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      showPasswordGuidelines: showPasswordGuidelines ?? this.showPasswordGuidelines,
    );
  }
}

class PasswordVisibilityNotifier extends StateNotifier<PasswordVisibilityState> {
  PasswordVisibilityNotifier() : super(PasswordVisibilityState());

  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(isCurrentPasswordVisible: !state.isCurrentPasswordVisible);
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void toggleGuidelines() {
    state = state.copyWith(showPasswordGuidelines: !state.showPasswordGuidelines);
  }
}

class PasswordState {
  final String newPassword;
  final String confirmPassword;
  final bool requireSignIn;

  PasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.requireSignIn = true,
  });

  bool get isSaveEnabled => newPassword.length >= 8 && newPassword == confirmPassword;

  PasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? requireSignIn,
  }) {
    return PasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      requireSignIn: requireSignIn ?? this.requireSignIn,
    );
  }
}

class PasswordStateNotifier extends StateNotifier<PasswordState> {
  PasswordStateNotifier() : super(PasswordState());

  void updatePasswords(String newPassword, String confirmPassword) {
    state = state.copyWith(newPassword: newPassword, confirmPassword: confirmPassword);
  }

  void toggleRequireSignIn() {
    state = state.copyWith(requireSignIn: !state.requireSignIn);
  }
}

class ChangePasswordPage extends ConsumerWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibilityState = ref.watch(passwordVisibilityProvider);
    final passwordState = ref.watch(passwordStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password', style: AppTextStyles.headline1),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create a new password that is at least 8 characters long.", style: AppTextStyles.bodyText1),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: ref.read(passwordVisibilityProvider.notifier).toggleGuidelines,
              icon: const Icon(Icons.shield, color: Colors.blue),
              label: const Text("What makes a strong password?", style: AppTextStyles.headline2),
            ),
            if (visibilityState.showPasswordGuidelines)
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Choose a strong password to\nprotect your account\n", style: AppTextStyles.headline2),
                      Text("• It should be a mix of letters, numbers, and special characters", style: AppTextStyles.bodyText1),
                      Text("• It should be at least 8 characters long", style: AppTextStyles.bodyText1),
                      Text("• It should not contain your name, phone number or email address", style: AppTextStyles.bodyText1)
                    ],
                  ),
                ),
              ),
            _buildPasswordField("Type your current password", visibilityState.isCurrentPasswordVisible, ref.read(passwordVisibilityProvider.notifier).toggleCurrentPasswordVisibility),
            _buildPasswordField("Type your new password", visibilityState.isNewPasswordVisible, ref.read(passwordVisibilityProvider.notifier).toggleNewPasswordVisibility, (value) => ref.read(passwordStateProvider.notifier).updatePasswords(value, passwordState.confirmPassword)),
            _buildPasswordField("Retype your new password", visibilityState.isConfirmPasswordVisible, ref.read(passwordVisibilityProvider.notifier).toggleConfirmPasswordVisibility, (value) => ref.read(passwordStateProvider.notifier).updatePasswords(passwordState.newPassword, value)),
            Row(
              children: [
                Checkbox(
                  value: passwordState.requireSignIn,
                  onChanged: (_) => ref.read(passwordStateProvider.notifier).toggleRequireSignIn(),
                ),
                const Text("Require all devices to sign in with new password", style: AppTextStyles.bodyText2),
              ],
            ),
            ElevatedButton(
              style: AppButtonStyles.elevatedButton,
              onPressed: passwordState.isSaveEnabled ? () {} : null,
              child: const Text("Save Password"),
            ),
            OutlinedButton(
              style: AppButtonStyles.outlinedButton,
              onPressed: () {},
              child: const Text("Forgot Password"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, bool isVisible, VoidCallback toggleVisibility, [Function(String)? onChanged]) {
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
