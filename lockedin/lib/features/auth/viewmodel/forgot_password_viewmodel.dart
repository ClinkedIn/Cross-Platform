import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/repository/auth_repository.dart';
import 'package:lockedin/features/auth/repository/auth_repository_impl.dart';
import 'package:lockedin/features/auth/services/auth_service.dart';

// Define authRepositoryProvider here if not defined in another file
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(AuthService());
});

class ForgotPasswordViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> sendForgotPasswordRequest(String emailOrPhone) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.forgotPassword(emailOrPhone);
      state = const AsyncValue.data(null); // Success
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Define the Riverpod provider for the ViewModel
final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordViewModel, AsyncValue<void>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return ForgotPasswordViewModel(authRepo);
});
