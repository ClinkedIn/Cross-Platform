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
}
