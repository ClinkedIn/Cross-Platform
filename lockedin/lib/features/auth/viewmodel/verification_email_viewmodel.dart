import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/repository/email_verification_repository.dart';

class VerificationEmailViewModel extends ChangeNotifier {
  final EmailVerificationRepository _repository;
  VerificationEmailViewModel(this._repository);

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
    try {
      _receivedCode = "";
      notifyListeners();

      final code = await _repository.sendVerificationEmail();
      if (code != null) {
        _receivedCode = code;
        print("New Code Fetched: $_receivedCode");
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching verification code: $e");
    }
  }

  void updateCode(String value) {
    _userInputCode = value;
    _isCodeValid = (_userInputCode == _receivedCode);
    notifyListeners();
  }

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

    try {
      final code = await _repository.sendVerificationEmail();
      if (code != null) {
        _receivedCode = code;
        print("Resent Code: $_receivedCode");
        notifyListeners();
      }
    } catch (e) {
      print("Error resending verification code: $e");
    }

    Future.delayed(const Duration(seconds: 10), () {
      _isResendDisabled = false;
      notifyListeners();
    });
  }
}
