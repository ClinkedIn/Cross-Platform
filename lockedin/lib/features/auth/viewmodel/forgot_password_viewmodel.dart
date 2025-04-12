import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/repository/forgot_password_repository.dart';

// Define the provider for ForgotPasswordRepository
final forgotPasswordRepositoryProvider = Provider<ForgotPasswordRepository>((ref) {
  return ForgotPasswordRepository();
});

class ForgotPasswordViewModel extends StateNotifier<AsyncValue<void>> {
  final ForgotPasswordRepository _forgotPasswordRepository;

  ForgotPasswordViewModel(this._forgotPasswordRepository) : super(const AsyncValue.data(null));

  // Method to send the forgot password request
  Future<void> sendForgotPasswordRequest(String emailOrPhone) async {
    state = const AsyncValue.loading();
    try {
      await _forgotPasswordRepository.forgotPassword(emailOrPhone);
      state = const AsyncValue.data(null); // Success
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Validation method for email or phone number
  String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Field cannot be empty";
    } 
      
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    final phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");
      
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return "Enter a valid email address or phone number";
    }
      
    return null; // validation passed
  }
}

// Define the Riverpod provider for the ViewModel
final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordViewModel, AsyncValue<void>>((ref) {
  final forgotPasswordRepo = ref.watch(forgotPasswordRepositoryProvider);
  return ForgotPasswordViewModel(forgotPasswordRepo);
});