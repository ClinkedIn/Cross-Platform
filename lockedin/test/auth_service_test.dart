import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lockedin/features/auth/repository/auth_service.dart';

import 'auth_service_test.mocks.dart'; // Auto-generated file

@GenerateMocks([
  AuthService,
]) // This tells build_runner to generate MockAuthService
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  test('Successful login returns token', () async {
    when(
      mockAuthService.login('test@example.com', 'password123'),
    ).thenAnswer((_) async => 'mock_token');

    final token = await mockAuthService.login(
      'test@example.com',
      'password123',
    );

    expect(token, 'mock_token');
  });

  test('Failed login throws exception', () async {
    when(
      mockAuthService.login('wrong@example.com', 'wrongpassword'),
    ).thenThrow(Exception('Invalid email or password'));

    expect(
      () => mockAuthService.login('wrong@example.com', 'wrongpassword'),
      throwsException,
    );
  });
}
