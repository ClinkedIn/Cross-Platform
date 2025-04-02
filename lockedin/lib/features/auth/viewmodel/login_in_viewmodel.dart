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
  state = const AsyncValue.loading();
  try {
    print('Starting Google Sign-In');
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      print('Google Sign-In canceled by user');
      state = const AsyncValue.data(null);
      return;
    }
    print('Google User: ${googleUser.email}');
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print('Google Access Token: ${googleAuth.accessToken}');
    print('Google ID Token: ${googleAuth.idToken}');
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('Credential created, signing in with Firebase');
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print('Firebase sign-in complete, fetching ID token');
    final idToken = await userCredential.user?.getIdToken();
    if (idToken != null) {
      print('Firebase ID Token: $idToken');
      await TokenService.saveToken(idToken);
    } else {
      print('No Firebase ID Token received');
    }
    state = const AsyncValue.data(null);
  } catch (e, stackTrace) {
    print('Google Sign-In Error: $e\nStackTrace: $stackTrace');
    state = AsyncValue.error(e, stackTrace);
  }
 }
}