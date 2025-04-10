import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/profile/repository/profile/profile_api.dart';
import 'package:lockedin/features/profile/state/user_state.dart';
import 'package:flutter/material.dart';

class ProfileViewModel {
  final Ref ref;

  ProfileViewModel(this.ref);

  Future<void> fetchUser(BuildContext context) async {
    try {
      final user = await ProfileService().fetchUserData();
      ref.read(userProvider.notifier).setUser(user);
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Unauthorized')) {
        TokenService.deleteCookie();

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    }
  }
}

final profileViewModelProvider = Provider((ref) => ProfileViewModel(ref));
