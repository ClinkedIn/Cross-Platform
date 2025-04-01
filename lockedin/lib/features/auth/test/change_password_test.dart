import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/auth/viewmodel/change_password_viewmodel.dart';
import 'package:lockedin/features/auth/view/change_password_page.dart';

void main() {
  late MockAuthService mockAuthService;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://mockuri.com'));
    registerFallbackValue(
      ChangePasswordRequest(
        newPassword: 'dummyNewPassword',
        currentPassword: 'dummyCurrentPassword',
      ),
    );
  });

  setUp(() {
    mockAuthService = MockAuthService();
    container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(mockAuthService),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  group('PasswordStateNotifier', () {
    test('should change password successfully', () async {
      when(() => mockAuthService.changePasswordRequest(any()))
          .thenAnswer((_) async => true);

      // Create the viewModel properly using the provider from the container
      final viewModel = container.read(changePasswordViewModelProvider.notifier);

      await viewModel.changePassword('newPassword123', 'currentPassword123');

      expect(container.read(changePasswordViewModelProvider), const AsyncValue.data(true));
      verify(() => mockAuthService.changePasswordRequest(any())).called(1);
    });

    test('should handle API failure and set error state', () async {
      when(() => mockAuthService.changePasswordRequest(any()))
          .thenAnswer((_) async => false);

      final viewModel = container.read(changePasswordViewModelProvider.notifier);

      await viewModel.changePassword('newPassword123', 'currentPassword123');

      expect(container.read(changePasswordViewModelProvider), const AsyncValue.data(false));
      verify(() => mockAuthService.changePasswordRequest(any())).called(1);
    });

    test('should handle API exception and set error state', () async {
      when(() => mockAuthService.changePasswordRequest(any()))
          .thenThrow(Exception('API Error'));

      final viewModel = container.read(changePasswordViewModelProvider.notifier);

      await viewModel.changePassword('newPassword123', 'currentPassword123');

      expect(container.read(changePasswordViewModelProvider), isA<AsyncError>());
      expect(container.read(changePasswordViewModelProvider).error, isA<Exception>());
    });
  });

  group('AuthService', () {
    late MockHttpClient mockClient;
    late AuthService authService;

    setUp(() {
      mockClient = MockHttpClient();
      authService = AuthService(client: mockClient);
    });

    test('should return true on successful password change', () async {
      final response = http.Response('{"message": "Password changed successfully"}', 200);

      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenAnswer((_) async => response);

      final success = await authService.changePasswordRequest(
        ChangePasswordRequest(
          newPassword: 'newPassword123',
          currentPassword: 'currentPassword123',
        ),
      );

      expect(success, true);
      verify(() => mockClient.patch(any(), body: any(named: 'body'))).called(1);
    });

    test('should return false on failure response', () async {
      final response = http.Response('{"message": "Error changing password"}', 400);

      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenAnswer((_) async => response);

      final success = await authService.changePasswordRequest(
        ChangePasswordRequest(
          newPassword: 'newPassword123',
          currentPassword: 'currentPassword123',
        ),
      );

      expect(success, false);
      verify(() => mockClient.patch(any(), body: any(named: 'body'))).called(1);
    });

    test('should return false on network exception', () async {
      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenThrow(Exception('Network Error'));

      final success = await authService.changePasswordRequest(
        ChangePasswordRequest(
          newPassword: 'newPassword123',
          currentPassword: 'currentPassword123',
        ),
      );

      expect(success, false);
      verify(() => mockClient.patch(any(), body: any(named: 'body'))).called(1);
    });
  });
}

class MockAuthService extends Mock implements AuthService {}
class MockHttpClient extends Mock implements http.Client {}