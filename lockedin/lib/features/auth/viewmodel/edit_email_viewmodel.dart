import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/repository/edit_email_repository.dart';

class EditEmailViewModel extends ChangeNotifier {
  final EditEmailRepository _repository;

  EditEmailViewModel(this._repository);

  String? emailError;
  bool isEmailValid = false;
  bool isLoading = false;
  String? apiMessage;

  void validateEmailOrPhone(String input) {
    print("🔍 Validating input: $input");

    if (RegExp(r'^\+?[ 0-9]+$').hasMatch(input)) {
      if (!input.startsWith('+')) {
        emailError =
            "❌ Please enter a valid phone number, including '+' when using a country code.";
        isEmailValid = false;
      } else {
        emailError = null;
        isEmailValid = true;
      }
      notifyListeners();
      return;
    }

    if (RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(input)) {
      emailError = null;
      isEmailValid = true;
    } else {
      emailError =
          "❌ Invalid input. Please enter a valid email or phone number.";
      isEmailValid = false;
    }

    notifyListeners();
  }

  Future<void> updateEmail(String newEmail, String password) async {
    validateEmailOrPhone(
      newEmail,
    ); // Ensure validation runs before checking isEmailValid

    if (!isEmailValid) return;

    isLoading = true;
    apiMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateEmail(newEmail, password);

      if (result.containsKey('message')) {
        apiMessage = result['message'];

        if (apiMessage == "Email updated successfully") {
          emailError = null;
        }
      } else {
        apiMessage = "An unexpected error occurred.";
      }
    } catch (e) {
      apiMessage = "Failed to update email. Please try again.";
    }

    isLoading = false;
    notifyListeners();
  }

  void resetMessages() {
    apiMessage = null;
    emailError = null;
    notifyListeners();
  }
}
