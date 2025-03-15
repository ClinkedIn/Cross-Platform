import 'package:flutter/material.dart';

class EditEmailViewModel extends ChangeNotifier {
  String? emailError;
  bool isEmailValid = false;

  void validateEmail(String email) {
    if (email.isEmpty || !email.contains("@")) {
      emailError = "Enter a valid email address";
      isEmailValid = false;
    } else {
      emailError = null;
      isEmailValid = true;
    }
    notifyListeners();
  }
}
