import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lockedin/data/repositories/posts/fake_sign_up_api.dart';

class SignupViewModel extends Notifier<SignupState> {
  final FakeSignUpApi _api = FakeSignUpApi(); // Fake API instance
  final _secureStorage = FlutterSecureStorage(); // Secure storage instance

  @override
  SignupState build() {
    return SignupState(); // ✅ Provide initial state
  }

  void setFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void setLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  String? validateEmailOrPhone(String input) {
    if (RegExp(r'^\+?[0-9]+$').hasMatch(input)) {
      if (!input.startsWith('+')) {
        return "❌ Please enter a valid phone number, including '+' when using a country code.";
      } else {
        return null;
      }
    } else if (RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(input)) {
      return null;
    }
    return "❌ Invalid input. Please enter a valid email or phone number.";
  }

  bool get isFormValid =>
      state.firstName.isNotEmpty &&
      state.lastName.isNotEmpty &&
      state.email.isNotEmpty &&
      state.password.isNotEmpty;

  Future<void> submitForm() async {
    print('✅ Submit button pressed');
    print('First Name: ${state.firstName}');
    print('Last Name: ${state.lastName}');
    print('Email: ${state.email}');
    print('Password: ${state.password}');
    print('Remember Me: ${state.rememberMe}');

    if (!isFormValid) {
      print('❌ Error: All fields must be filled!');
      return;
    }

    String? validationMessage = validateEmailOrPhone(state.email);
    if (validationMessage != null) {
      print(validationMessage);
      return;
    }

    state = state.copyWith(isLoading: true);

    bool success = await _api.registerUser(
      state.firstName,
      state.lastName,
      state.email,
      state.password,
      state.rememberMe,
    );

    state = state.copyWith(isLoading: false, success: success);

    if (success && state.rememberMe) {
      await _secureStorage.write(key: 'email', value: state.email);
      await _secureStorage.write(key: 'password', value: state.password);
      print('🔐 Credentials saved securely!');
    }

    if (success) {
      print('✅ Signup successful');
    } else {
      print('❌ Signup failed. Please try again.');
    }
  }

  Future<void> loadSavedCredentials() async {
    String? email = await _secureStorage.read(key: 'email');
    String? password = await _secureStorage.read(key: 'password');

    if (email != null && password != null) {
      state = state.copyWith(
        email: email,
        password: password,
        rememberMe: true,
      );
      print('🔄 Loaded saved credentials');
    }
  }

  Future<void> clearSavedCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
    state = state.copyWith(email: '', password: '', rememberMe: false);
    print('🗑️ Secure storage cleared');
  }
}

final signupProvider = NotifierProvider<SignupViewModel, SignupState>(
  SignupViewModel.new,
);

class SignupState {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool rememberMe;
  final bool isLoading;
  final bool success;

  SignupState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.isLoading = false,
    this.success = false,
  });

  SignupState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    bool? rememberMe,
    bool? isLoading,
    bool? success,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
    );
  }
}
