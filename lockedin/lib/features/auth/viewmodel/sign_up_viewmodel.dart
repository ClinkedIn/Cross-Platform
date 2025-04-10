import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lockedin/features/auth/repository/sign_up_repository.dart';
import 'package:lockedin/features/auth/state/sign_up_state.dart';
import 'dart:convert';

class SignupViewModel extends Notifier<SignupState> {
  final SignupRepository _repository = SignupRepository();
  final _secureStorage = const FlutterSecureStorage();
  //manage reactive state
  @override
  SignupState build() {
    return const SignupState(
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      rememberMe: false,
      isLoading: false,
      success: false,
    );
  }
  //update state

  void setFirstName(String value) => state = state.copyWith(firstName: value);
  void setLastName(String value) => state = state.copyWith(lastName: value);
  void setEmail(String value) => state = state.copyWith(email: value);
  void setPassword(String value) => state = state.copyWith(password: value);
  void setRememberMe(bool value) => state = state.copyWith(rememberMe: value);

  String? validateEmailOrPhone(String input) {
    print("🔍 Validating input: $input");

    if (RegExp(r'^\+?[ 0-9]+$').hasMatch(input)) {
      if (!input.startsWith('+')) {
        print("❌ Invalid phone format");
        return "❌ Please enter a valid phone number, including '+' when using a country code.";
      }
      print("✅ Valid phone number");
      return null;
    }

    if (RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(input)) {
      print("✅ Valid email");
      return null;
    }

    print("❌ Invalid email ");
    return "❌ Invalid input. Please enter a valid email.";
  }

  bool get isFormValid =>
      state.firstName.isNotEmpty &&
      state.lastName.isNotEmpty &&
      state.email.isNotEmpty &&
      state.password.isNotEmpty;

  Future<void> submitForm() async {
    print('✅ Submit button pressed');

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

    try {
      final startTime = DateTime.now();
      final response = await _repository.registerUser(
        firstName: state.firstName,
        lastName: state.lastName,
        email: state.email,
        password: state.password,
        rememberMe: state.rememberMe,
      );
      final endTime = DateTime.now();
      print(
        "⏳ API Call Duration: ${endTime.difference(startTime).inMilliseconds}ms",
      );

      print("📨 Server response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("✅ Signup successful: ${responseData["message"]}");

        state = state.copyWith(
          success: true,
          isLoading: false,
          email: responseData["email"],
        );

        if (state.rememberMe) {
          Future.microtask(() async {
            await _secureStorage.write(key: 'email', value: state.email);
            await _secureStorage.write(key: 'password', value: state.password);
            print('🔐 Credentials saved securely in the background!');
          });
        }

        print(
          "✅ State updated: success=${state.success}, email=${state.email}",
        );
      } else {
        print('❌ Signup failed. Server responded with: ${response.body}');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('❌ Signup failed due to network error: $e');
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
