import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/utils/picture_loader.dart';
import 'package:mocktail/mocktail.dart';

// Mock User class (replace with your actual model class)
class MockUser extends Mock implements UserModel {}

void main() {
  group('getUserProfileImage', () {
    test('returns NetworkImage when profile picture is valid', () {
      final user = MockUser();
      when(
        () => user.profilePicture,
      ).thenReturn('https://example.com/profile.jpg');

      final asyncUser = AsyncValue.data(user);

      final image = getUserProfileImage(asyncUser);

      expect(image, isA<NetworkImage>());
      expect((image as NetworkImage).url, 'https://example.com/profile.jpg');
    });

    test('returns AssetImage when profile picture is null or empty', () {
      final user = MockUser();
      when(() => user.profilePicture).thenReturn(null); // Null profile picture
      final asyncUser = AsyncValue.data(user);

      final image = getUserProfileImage(asyncUser);

      expect(image, isA<AssetImage>());
      expect(
        (image as AssetImage).assetName,
        'assets/images/default_profile_photo.png',
      );
    });

    test('returns AssetImage when AsyncValue is in error state', () {
      final asyncUser = AsyncValue.error('Some error', StackTrace.current);

      final image = getUserProfileImage(asyncUser);

      expect(image, isA<AssetImage>());
      expect(
        (image as AssetImage).assetName,
        'assets/images/default_profile_photo.png',
      );
    });

    test('returns AssetImage when AsyncValue is in loading state', () {
      final asyncUser = AsyncValue.loading();

      final image = getUserProfileImage(asyncUser);

      expect(image, isA<AssetImage>());
      expect(
        (image as AssetImage).assetName,
        'assets/images/default_profile_photo.png',
      );
    });
  });

  group('getUsercoverImage', () {
    test('returns NetworkImage when cover picture is valid', () {
      final user = MockUser();
      when(() => user.coverPicture).thenReturn('https://example.com/cover.jpg');

      final asyncUser = AsyncValue.data(user);

      final image = getUsercoverImage(asyncUser);

      expect(image, isA<NetworkImage>());
      expect((image as NetworkImage).url, 'https://example.com/cover.jpg');
    });

    test('returns AssetImage when cover picture is null or empty', () {
      final user = MockUser();
      when(() => user.coverPicture).thenReturn(null); // Null cover picture
      final asyncUser = AsyncValue.data(user);

      final image = getUsercoverImage(asyncUser);

      expect(image, isA<AssetImage>());
      expect(
        (image as AssetImage).assetName,
        'assets/images/default_cover_photo.jpeg',
      );
    });

    test('returns AssetImage when AsyncValue is in error state', () {
      final asyncUser = AsyncValue.error('Some error', StackTrace.current);

      final image = getUsercoverImage(asyncUser);

      expect(image, isA<AssetImage>());
      expect(
        (image as AssetImage).assetName,
        'assets/images/default_cover_photo.jpeg',
      );
    });

    test('returns AssetImage when AsyncValue is in loading state', () {
      final asyncUser = AsyncValue.loading();

      final image = getUsercoverImage(asyncUser);

      expect(image, isA<AssetImage>());
      expect(
        (image as AssetImage).assetName,
        'assets/images/default_cover_photo.jpeg',
      );
    });
  });
}
