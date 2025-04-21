import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/repository/forget password repositories/new_password_repository.dart';

// Define the provider for NewPasswordRepository
final newPasswordRepositoryProvider = Provider<NewPasswordRepository>((ref) {
  return NewPasswordRepository();
});

class NewPasswordViewModel extends StateNotifier<AsyncValue<void>> {
  final NewPasswordRepository _newPasswordRepository;
  final String resetToken;
  
  NewPasswordViewModel(this._newPasswordRepository, this.resetToken) : super(const AsyncValue.data(null));
  
  // Password validation logic
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  // Confirm password validation logic
  String? validateConfirmPassword(String password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  // Reset password logic
  Future<void> resetPassword(String newPassword, bool requireSignIn) async {
    state = const AsyncValue.loading();
    try {
      await _newPasswordRepository.resetPassword(resetToken, newPassword);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Define the provider factory that requires a token parameter
final newPasswordProvider = StateNotifierProvider.family<NewPasswordViewModel, AsyncValue<void>, String>((ref, token) {
  final newPasswordRepo = ref.watch(newPasswordRepositoryProvider);
  return NewPasswordViewModel(newPasswordRepo, token);
});