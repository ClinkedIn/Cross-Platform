import 'package:lockedin/features/auth/repository/auth_repository.dart';
import 'package:lockedin/features/auth/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  @override
  Future<void> forgotPassword(String emailOrPhone) async {
    try {
      await _authService.forgotPassword(emailOrPhone);
    } catch (e) {
      throw Exception("Failed to reset password");
    }
  }

// This method will be called when the user submits the new password
  // It will send the new password to the server and handle the response
  // If requireSignIn is true, it will also sign out the user after resetting the password
@override
Future<void> resetPassword(String newPassword, bool requireSignIn) async {
  try {
    await _authService.resetPassword(newPassword, requireSignIn);
  } catch (e) {
    throw Exception("Failed to reset password: ${e.toString()}");
  }
}
}
