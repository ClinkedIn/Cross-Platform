import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/auth/repository/sign_up_repository.dart';

enum SignupState { initial, loading, error, otpSent, otpVerified, success }

class SignupViewModel extends ChangeNotifier {
  final SignupRepository _signupRepository = SignupRepository();

  SignupState _state = SignupState.initial;
  String _errorMessage = '';
  int _currentPage = 0;
  bool _rememberMe = true;

  // User data
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _otp = '';

  // Getters
  SignupState get state => _state;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get rememberMe => _rememberMe;
  double get progressPercentage => (_currentPage + 1) / 4;

  // User data getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String get otp => _otp;

  // Setters
  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setOtp(String value) {
    _otp = value;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Navigation methods
  void nextPage() {
    if (_currentPage < 3) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  // Form validation
  bool isNameFormValid() {
    return _firstName.isNotEmpty && _lastName.isNotEmpty;
  }

  bool isEmailValid() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(_email);
  }

  bool isPasswordValid() {
    // Password should be at least 8 characters with at least one uppercase letter,
    // one lowercase letter, one number, and one special character
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
    );
    return passwordRegex.hasMatch(_password);
  }

  bool isOtpValid() {
    return _otp.length == 6 && int.tryParse(_otp) != null;
  }

  // API calls
  Future<void> signUp(BuildContext context) async {
    try {
      _state = SignupState.loading;
      notifyListeners();

      final response = await _signupRepository.registerUser(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        password: _password,
        rememberMe: _rememberMe,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _state = SignupState.otpSent;
        nextPage(); // Move to OTP verification page
      } else {
        _state = SignupState.error;
        _errorMessage = 'Failed to register. Please try again.';
      }
    } catch (e) {
      _state = SignupState.error;
      _errorMessage = 'An error occurred. Please check your connection.';
    }

    notifyListeners();
  }

  Future<void> verifyOtp(BuildContext context) async {
    try {
      _state = SignupState.loading;
      notifyListeners();

      final response = await _signupRepository.verifyEmailOTP(
        email: _email,
        otp: _otp,
      );

      if (response.statusCode == 200) {
        _state = SignupState.success;
        notifyListeners();

        // Navigate to home screen after successful signup
        GoRouter.of(context).go('/');
      } else {
        _state = SignupState.error;
        _errorMessage = 'Invalid OTP. Please try again.';
      }
    } catch (e) {
      _state = SignupState.error;
      _errorMessage = 'An error occurred. Please check your connection.';
    }

    notifyListeners();
  }

  void resetError() {
    _state = SignupState.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
