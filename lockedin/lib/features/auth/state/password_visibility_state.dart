import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds visibility states for all password fields and password guideline section
@immutable
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
