import 'package:lockedin/features/auth/repository/auth_repository.dart';
import 'package:lockedin/features/auth/services/auth_service.dart';

/// This class implements the AuthRepository interface and provides the actual implementation of the methods defined in the interface.
/// It uses the AuthService to perform the actual API calls for login, forgot password, and reset password functionalities.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);



  @override
  Future<void> forgotPassword(String emailOrPhone) async {
    try {
      await _authService.forgotPassword(emailOrPhone);
    } catch (e) {
      throw Exception("Failed to reset password");
    }
  }

 
  
}
