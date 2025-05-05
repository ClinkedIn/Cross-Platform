import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/viewmodel/change_password_viewmodel.dart';
import 'package:lockedin/features/auth/state/password_visibility_state.dart';
import 'package:lockedin/features/auth/state/password_state.dart';

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
