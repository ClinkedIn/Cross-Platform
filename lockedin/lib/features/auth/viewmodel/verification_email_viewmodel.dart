import 'dart:async';
import 'package:flutter/material.dart';

class VerificationEmailViewModel extends ChangeNotifier {
  String _receivedCode = "";
  String _userInputCode = "";
  bool _isCodeValid = false;
  bool _isResendDisabled = false;
  String _email = "";

  String get receivedCode => _receivedCode;
  bool get isCodeValid => _isCodeValid;
  bool get isResendDisabled => _isResendDisabled;
  String get email => _email;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  Future<void> fetchVerificationCode() async {
    _receivedCode = "";
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _receivedCode = (100000 + (DateTime.now().millisecond % 900000)).toString();
    print("New Code Fetched: $_receivedCode");
    notifyListeners();
  }

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

  Future<void> resendCode() async {
    if (_isResendDisabled) return;

    _isResendDisabled = true;
    notifyListeners();

    await fetchVerificationCode();

    Future.delayed(const Duration(seconds: 10), () {
      _isResendDisabled = false;
      notifyListeners();
    });
  }
}
