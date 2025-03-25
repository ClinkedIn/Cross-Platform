import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/auth/viewmodel/change_password_viewmodel.dart';

void main() {
  late AuthService mockAuthService;
  late ChangePasswordViewModel viewModel;
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://mockuri.com'));
  // Register fallback values for mocking
    registerFallbackValue(ChangePasswordRequest(
      newPassword: 'dummyNewPassword',
      currentPassword: 'dummyCurrentPassword',
    ));
  });

  setUp(() {
    // Initialize mock services before each test
    mockAuthService = MockAuthService();
    viewModel = ChangePasswordViewModel(mockAuthService);
  });

  group('ChangePasswordViewModel', () {
    test('should change password successfully', () async {
      // Arrange: mock the AuthService to return true for successful password change
      when(() => mockAuthService.changePassword(any()))
          .thenAnswer((_) async => true);

      // Act: Call the changePassword function
      await viewModel.changePassword('newPassword123', 'currentPassword123');

      // Assert: Verify that the state is updated to success
      expect(viewModel.state, const AsyncValue.data(true));
      verify(() => mockAuthService.changePassword(any())).called(1);
    });

    test('should handle API failure and set error state', () async {
      // Arrange: mock the AuthService to throw an exception or return false on failure
      when(() => mockAuthService.changePassword(any()))
          .thenAnswer((_) async => false);

      // Act: Call the changePassword function
      await viewModel.changePassword('newPassword123', 'currentPassword123');

      // Assert: Verify that the state is set to error
      expect(viewModel.state, const AsyncValue.data(false));
      verify(() => mockAuthService.changePassword(any())).called(1);
    });

    test('should handle API exception and set error state', () async {
    // Arrange: mock the AuthService to throw an exception
    when(() => mockAuthService.changePassword(any()))
        .thenThrow(Exception('API Error'));

    // Act: Call the changePassword function
    await viewModel.changePassword('newPassword123', 'currentPassword123');

    // Assert: Verify that the state is set to error
    expect(viewModel.state, isA<AsyncError>());
    // Optionally, verify the error message or stack trace
    expect(viewModel.state.error, isA<Exception>());
  });
  });

  group('AuthService', () {
    test('should return true on successful password change', () async {
      // Arrange: Mock a successful response from the HTTP client
      final response = http.Response('{"message": "Password changed successfully"}', 200);
      final mockClient = MockHttpClient();
      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenAnswer((_) async => response);

      final service = AuthService(client: mockClient);

      // Act: Call the changePassword function
      final success = await service.changePassword(ChangePasswordRequest(
        newPassword: 'newPassword123',
        currentPassword: 'currentPassword123',
      ));

      // Assert: Verify the result is success
      expect(success, true);
      verify(() => mockClient.patch(any(), body: any(named: 'body'))).called(1);
    });

    test('should return false on failure response', () async {
      // Arrange: Mock an error response from the HTTP client
      final response = http.Response('{"message": "Error changing password"}', 400);
      final mockClient = MockHttpClient();
      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenAnswer((_) async => response);

      final service = AuthService(client: mockClient);

      // Act: Call the changePassword function
      final success = await service.changePassword(ChangePasswordRequest(
        newPassword: 'newPassword123',
        currentPassword: 'currentPassword123',
      ));

      // Assert: Verify the result is failure
      expect(success, false);
      verify(() => mockClient.patch(any(), body: any(named: 'body'))).called(1);
    });

    test('AuthService should return false on exception', () async {
      // Arrange: Mock an exception being thrown for network error
      final mockClient = MockHttpClient();

      // Simulate a network error by throwing an exception
      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenThrow(Exception('Network Error'));

      final service = AuthService(client: mockClient);

      // Act: Call the changePassword function
      final success = await service.changePassword(ChangePasswordRequest(
        newPassword: 'newPassword123',
        currentPassword: 'currentPassword123',
      ));

      // Assert: Verify that the result is false since an exception occurred
      expect(success, false);

      // Verify that the patch method was called once
      verify(() => mockClient.patch(any(), body: any(named: 'body'))).called(1);
    });
  });
}

class MockAuthService extends Mock implements AuthService {}

class MockHttpClient extends Mock implements http.Client {}
