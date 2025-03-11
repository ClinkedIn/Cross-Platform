import 'dart:async';
import 'package:flutter/material.dart';

class VerificationEmailViewModel extends ChangeNotifier {
  String _receivedCode = ""; // Code sent from the backend
  String _userInputCode = ""; // User-entered code
  bool _isCodeValid = false;
  bool _isResendDisabled = false; // Controls resend button state

  String get receivedCode => _receivedCode;
  bool get isCodeValid => _isCodeValid;
  bool get isResendDisabled => _isResendDisabled;

  // Function to simulate fetching the verification code from the backend
  Future<void> fetchVerificationCode() async {
    _receivedCode = ""; // Clear old code (simulating waiting for a response)
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
    _receivedCode = (100000 + (DateTime.now().millisecond % 900000)).toString();
    print("New Code Fetched: $_receivedCode"); // Debugging purpose
    notifyListeners();
  }

  // Function to update the user-inputted code
  void updateCode(String value) {
    _userInputCode = value;
    _isCodeValid = (_userInputCode == _receivedCode);
    notifyListeners();
  }

  // Function to verify the code
  void verifyCode(BuildContext context) {
    if (_isCodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code Verified Successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Code! Please Try Again.")),
      );
    }
  }

  // Function to handle resending the verification code
  Future<void> resendCode() async {
    if (_isResendDisabled) return;

    _isResendDisabled = true;
    notifyListeners();

    await fetchVerificationCode();

    // Enable the resend button after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      _isResendDisabled = false;
      notifyListeners();
    });
  }
}
