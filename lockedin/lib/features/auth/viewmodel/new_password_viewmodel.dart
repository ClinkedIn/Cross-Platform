// // In features/auth/viewmodel/new_password_viewmodel.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lockedin/features/auth/repository/auth_repository.dart';
// import 'package:lockedin/features/auth/viewmodel/forgot_password_viewmodel.dart';

// class NewPasswordViewModel extends StateNotifier<AsyncValue<void>> {
//   final AuthRepository _authRepository;
  
//   NewPasswordViewModel(this._authRepository) : super(const AsyncValue.data(null));
  
//   // Password validation logic
//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password cannot be empty';
//     }
//     if (value.length < 8) {
//       return 'Password must be at least 8 characters long';
//     }
//     // Add more validation as needed
//     return null;
//   }
  
//   // Confirm password validation logic
//   String? validateConfirmPassword(String password, String? confirmPassword) {
//     if (confirmPassword == null || confirmPassword.isEmpty) {
//       return 'Please confirm your password';
//     }
//     if (confirmPassword != password) {
//       return 'Passwords do not match';
//     }
//     return null;
//   }
  
//   // Reset password logic
//   Future<void> resetPassword(String newPassword, bool requireSignIn) async {
//     state = const AsyncValue.loading();
//     try {
//       await _authRepository.resetPassword(newPassword, requireSignIn);
//       state = const AsyncValue.data(null);
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }
// }

// // Define the provider
// final newPasswordProvider = StateNotifierProvider<NewPasswordViewModel, AsyncValue<void>>((ref) {
//   final authRepo = ref.watch(authRepositoryProvider);
//   return NewPasswordViewModel(authRepo);
// });