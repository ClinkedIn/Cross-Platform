import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/repository/forget%20password%20repositories/verification_code_repository.dart';

// Define the state class to hold both token and email/phone
class VerificationState {
  final String token;
  final String emailOrPhone;
  final bool isLoading;
  final String? error;

  VerificationState({
    this.token = '',
    this.emailOrPhone = '',
    this.isLoading = false,
    this.error,
  });

  // Create a copy of the state with updated values
  VerificationState copyWith({
    String? token,
    String? emailOrPhone,
    bool? isLoading,
    String? error,
  }) {
    return VerificationState(
      token: token ?? this.token,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Define the provider for VerificationCodeRepository
final verificationCodeRepositoryProvider = Provider<VerificationCodeRepository>((ref) {
  return VerificationCodeRepository();
});

class VerificationCodeViewModel extends StateNotifier<VerificationState> {
  final VerificationCodeRepository _verificationCodeRepository;

  VerificationCodeViewModel(this._verificationCodeRepository) 
    : super(VerificationState());

  // Set the email or phone for later use (like resending code)
  void setEmailOrPhone(String emailOrPhone) {
    state = state.copyWith(emailOrPhone: emailOrPhone);
  }

  // Method to verify the OTP code
  Future<bool> verifyCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _verificationCodeRepository.verifyResetCode(code);
      state = state.copyWith(
        token: token,
        isLoading: false,
        error: null,
      );
      return true; // Verification successful
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false; // Verification failed
    }
  }

  // Method to resend the verification code
  Future<bool> resendCode() async {
    if (state.emailOrPhone.isEmpty) {
      state = state.copyWith(
        error: "Email or phone number not available",
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _verificationCodeRepository.resendVerificationCode(state.emailOrPhone);
      state = state.copyWith(isLoading: false, error: null);
      return true; // Resend successful
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false; // Resend failed
    }
  }

  // Validation method for verification code
  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter the verification code";
    } else if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return "Enter a valid 6-digit code";
    }
    return null; // validation passed
  }
}

// Define the Riverpod provider for the ViewModel
final verificationCodeProvider = StateNotifierProvider<VerificationCodeViewModel, VerificationState>((ref) {
  final verificationRepo = ref.watch(verificationCodeRepositoryProvider);
  return VerificationCodeViewModel(verificationRepo);
});