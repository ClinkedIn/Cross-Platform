abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> forgotPassword(String emailOrPhone);
  Future<void> resetPassword(String newPassword, bool requireSignIn); 
}
