import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns the correct [ImageProvider] for the user's profile picture.
ImageProvider getUserProfileImage(AsyncValue userState) {
  return userState.when(
    data: (user) {
      if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
        return NetworkImage(user.profilePicture!);
      } else {
        return const AssetImage('assets/images/default_profile_photo.png');
      }
    },
    error:
        (error, _) =>
            const AssetImage('assets/images/default_profile_photo.png'),
    loading: () => const AssetImage('assets/images/default_profile_photo.png'),
  );
}

/// Returns the correct [ImageProvider] for the user's cover picture.
ImageProvider getUsercoverImage(AsyncValue userState) {
  return userState.when(
    data: (user) {
      if (user.coverPicture != null && user.coverPicture!.isNotEmpty) {
        return NetworkImage(user.coverPicture!);
      } else {
        return const AssetImage('assets/images/default_cover_photo.jpeg');
      }
    },
    error:
        (error, _) =>
            const AssetImage('assets/images/default_cover_photo.jpeg'),
    loading: () => const AssetImage('assets/images/default_cover_photo.jpeg'),
  );
}
