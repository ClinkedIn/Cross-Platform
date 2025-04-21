import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/core/utils/validators.dart';

void main() {
  group('Email Validator', () {
    test('Returns error when email is null', () {
      expect(Validators.validateEmail(null), 'Email is required');
    });

    test('Returns error when email is empty', () {
      expect(Validators.validateEmail(''), 'Email is required');
    });

    test('Returns error when email is invalid', () {
      expect(Validators.validateEmail('invalid-email'), 'Invalid email format');
      expect(Validators.validateEmail('test@com'), 'Invalid email format');
      expect(Validators.validateEmail('test@.com'), 'Invalid email format');
    });

    test('Returns null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });
  });

  group('Password Validator', () {
    test('Returns error when password is null', () {
      expect(Validators.validatePassword(null), 'Password is required');
    });

    test('Returns error when password is empty', () {
      expect(Validators.validatePassword(''), 'Password is required');
    });

    test('Returns error when password is too short', () {
      expect(
        Validators.validatePassword('Ab1'),
        'Password must be at least 8 characters long',
      );
    });

    test('Returns error when password lacks uppercase letter', () {
      expect(
        Validators.validatePassword('password1'),
        'Password must contain at least one uppercase letter',
      );
    });

    test('Returns error when password lacks lowercase letter', () {
      expect(
        Validators.validatePassword('PASSWORD1'),
        'Password must contain at least one lowercase letter',
      );
    });

    test('Returns error when password lacks number', () {
      expect(
        Validators.validatePassword('Password'),
        'Password must contain at least one number',
      );
    });

    test('Returns null for valid password', () {
      expect(Validators.validatePassword('Passw0rd'), isNull);
    });
  });
}
