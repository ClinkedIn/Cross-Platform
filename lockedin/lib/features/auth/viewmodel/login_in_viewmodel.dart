import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/repository/auth_service.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  return LoginViewModel(ref);
});

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginViewModel(this.ref) : super(const AsyncValue.data(null));

  // Normal Email Login
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    print("Logging in with email: $email");

    try {
      final token = await AuthService().login(email, password);
      await TokenService.saveToken(token);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      print("Login error: $e");
    }
  }

  // Google Sign-In
  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    print("Signing in with Google...");

    try {
      print("ahhaah");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("Google User: $googleUser");
      if (googleUser == null) {
        print("Google Sign-In canceled.");
        state = const AsyncValue.data(null);
        return;
      }
     
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("Google Auth: $googleAuth");
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("Credential: $credential");
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      
      print("User: ${userCredential.user?.displayName}");

      // Get Firebase Token
      final String? firebaseToken = await userCredential.user?.getIdToken();
      print("Firebase Token: $firebaseToken");

      // Save Token to Your Token Service
      if (firebaseToken != null) {
        await TokenService.saveToken(firebaseToken);
      }

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      print("Google Sign-In error: $e");
    }
  }
}
