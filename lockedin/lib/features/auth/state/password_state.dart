import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representing all password-related input fields and messages
@immutable
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
