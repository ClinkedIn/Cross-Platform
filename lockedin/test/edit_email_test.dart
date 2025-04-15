import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lockedin/features/auth/repository/edit_email_repository.dart';
import 'package:lockedin/features/auth/viewmodel/edit_email_viewmodel.dart';

// Mock class for EditEmailRepository
class MockEditEmailRepository extends Mock implements EditEmailRepository {
  @override
  Future<Map<String, dynamic>> updateEmail(String email, String password) {
    return super.noSuchMethod(
      Invocation.method(#updateEmail, [email, password]),
      returnValue: Future.value({'message': 'Email updated successfully'}),
      returnValueForMissingStub: Future.value({
        'message': 'Email updated successfully',
      }),
    );
  }
}

void main() {
  late EditEmailViewModel viewModel;
  late MockEditEmailRepository mockRepository;

  setUp(() {
    mockRepository = MockEditEmailRepository();
    viewModel = EditEmailViewModel(mockRepository);
  });
  group('Email Validation', () {
    test('Valid email should pass validation', () {
      viewModel.validateEmailOrPhone('test@example.com');
      expect(viewModel.isEmailValid, true);
      expect(viewModel.emailError, isNull);
    });

    test('Invalid email should fail validation', () {
      viewModel.validateEmailOrPhone('invalid-email');
      expect(viewModel.isEmailValid, false);
      expect(viewModel.emailError, isNotNull);
    });

    test('Valid phone number should pass validation', () {
      viewModel.validateEmailOrPhone('+1234567890');
      expect(viewModel.isEmailValid, true);
      expect(viewModel.emailError, isNull);
    });

    test('Invalid phone number should fail validation', () {
      viewModel.validateEmailOrPhone('12345');
      expect(viewModel.isEmailValid, false);
      expect(viewModel.emailError, isNotNull);
    });
  });

  group('Email Update', () {
    test('Successful email update should update API message', () async {
      when(
        mockRepository.updateEmail('test@example.com', 'password123'),
      ).thenAnswer((_) async => {'message': 'Email updated successfully'});

      await viewModel.updateEmail('test@example.com', 'password123');

      expect(viewModel.isLoading, false);
      expect(viewModel.apiMessage, 'Email updated successfully');
      expect(viewModel.emailError, isNull);
    });

    test('Failed email update should set error message', () async {
      when(
        mockRepository.updateEmail('test@example.com', 'password123'),
      ).thenThrow(Exception('Network error'));

      await viewModel.updateEmail('test@example.com', 'password123');

      expect(viewModel.isLoading, false);
      expect(viewModel.apiMessage, 'Failed to update email. Please try again.');
    });
  });
}
