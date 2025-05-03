import 'package:lockedin/features/profile/model/user_model.dart';

class ProfileViewState {
  final UserModel user;
  final bool canSendConnectionRequest;

  ProfileViewState({
    required this.user,
    required this.canSendConnectionRequest,
  });
  ProfileViewState copyWith({UserModel? user, bool? canSendConnectionRequest}) {
    return ProfileViewState(
      user: user ?? this.user,
      canSendConnectionRequest:
          canSendConnectionRequest ?? this.canSendConnectionRequest,
    );
  }
}
