import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/auth/repository/email_verification_repository.dart';
import 'package:lockedin/features/auth/viewmodel/verification_email_viewmodel.dart';

// Fake Repository Implementation
class FakeEmailVerificationRepository implements EmailVerificationRepository {
  @override
  Future<String?> sendVerificationEmail() async {
    return "123456"; // Simulated response
  }
}

void main() {
  late FakeEmailVerificationRepository fakeRepository;
  late VerificationEmailViewModel viewModel;

  setUp(() {
    fakeRepository = FakeEmailVerificationRepository();
    viewModel = VerificationEmailViewModel(fakeRepository);
  });

  group('VerificationEmailViewModel Tests', () {
    test('fetchVerificationCode should update receivedCode', () async {
      // Act
      await viewModel.fetchVerificationCode();

      // Assert
      expect(viewModel.receivedCode, "123456");
    });

    test('updateCode should validate the code correctly', () async {
      // Act
      await viewModel.fetchVerificationCode(); // Ensure async completion

      viewModel.updateCode("123456");

      // Assert
      expect(viewModel.isCodeValid, isTrue);
    });

    test('resendCode should call API and update receivedCode', () async {
      // Act
      await viewModel.resendCode();

      // Assert
      expect(viewModel.receivedCode, "123456");
      expect(viewModel.isResendDisabled, isTrue);
    });
  });
}
