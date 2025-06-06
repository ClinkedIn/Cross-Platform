import 'package:flutter/foundation.dart';

@immutable
class SignupState {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool rememberMe;
  final bool isLoading;
  final bool success;
  final bool emailVerified; // Added for OTP verification

  const SignupState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.isLoading = false,
    this.success = false,
    this.emailVerified = false, // Default to false
  });

  SignupState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    bool? rememberMe,
    bool? isLoading,
    bool? success,
    bool? emailVerified,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
