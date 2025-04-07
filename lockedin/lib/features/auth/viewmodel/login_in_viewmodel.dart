import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  return LoginViewModel(ref);
});

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginViewModel(this.ref) : super(const AsyncValue.data(null));

  // Existing email/password login with error logging
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final token = await AuthService().login(email, password);
      await TokenService.saveToken(token);
      print('Email/Password Login Token: $token'); // Optional: Log token
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      print('Email/Password Login Error: $e\nStackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Updated Google Sign-In method with token and error logging
  Future<void> signInWithGoogle() async {
    try {
    // Initialize GoogleSignIn with scopes
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Check if user aborted the sign-in
    if (googleUser == null) {
      print("Sign-in aborted by user");
      return;
    }

    // Get authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("Access Token: ${googleAuth.accessToken}");
    print("ID Token: ${googleAuth.idToken}");

    // Validate tokens
    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw Exception("Google authentication tokens are missing");
    }

    // Create Firebase credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    // Get Firebase Token
    final String? firebaseToken = await userCredential.user?.getIdToken();
    print("Firebase Token: $firebaseToken");
    
    print("Signed in user: ${userCredential.user?.uid}");
  } catch (e) {
    print("Google Sign-In error: $e");
    rethrow; // Optional: rethrow for further handling
  }
}
}