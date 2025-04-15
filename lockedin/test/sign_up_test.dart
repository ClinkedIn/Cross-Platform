import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/features/auth/state/sign_up_state.dart';
import 'package:lockedin/features/auth/repository/sign_up_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockSignupRepository extends Mock implements SignupRepository {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late ProviderContainer container;
  late SignupViewModel viewModel;
  late MockSignupRepository mockRepository;
  late MockSecureStorage mockSecureStorage;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepository = MockSignupRepository();
    mockSecureStorage = MockSecureStorage();

    container = ProviderContainer(
      overrides: [signupProvider.overrideWith(() => SignupViewModel())],
    );

    viewModel = container.read(signupProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('SignupViewModel Tests', () {
    test('Initial state should be empty', () {
      expect(viewModel.state, const SignupState());
    });

    test('Set first name updates state', () {
      viewModel.setFirstName('John');
      expect(viewModel.state.firstName, 'John');
    });

    test('Set last name updates state', () {
      viewModel.setLastName('Doe');
      expect(viewModel.state.lastName, 'Doe');
    });

    test('Set email updates state', () {
      viewModel.setEmail('test@example.com');
      expect(viewModel.state.email, 'test@example.com');
    });

    test('Set password updates state', () {
      viewModel.setPassword('securePassword');
      expect(viewModel.state.password, 'securePassword');
    });

    test('Set rememberMe updates state', () {
      viewModel.setRememberMe(true);
      expect(viewModel.state.rememberMe, true);
    });

    test('Form validation fails for empty fields', () {
      viewModel.setFirstName('');
      viewModel.setLastName('');
      viewModel.setEmail('');
      viewModel.setPassword('');
      expect(viewModel.isFormValid, false);
    });

    test('Form validation passes with valid input', () {
      viewModel.setFirstName('John');
      viewModel.setLastName('Doe');
      viewModel.setEmail('test@example.com');
      viewModel.setPassword('securePassword');
      expect(viewModel.isFormValid, true);
    });

    test('Valid email is accepted', () {
      expect(viewModel.validateEmailOrPhone('test@example.com'), null);
    });

    test('Invalid email is rejected', () {
      expect(viewModel.validateEmailOrPhone('invalid-email'), isNotNull);
    });

    test('Valid phone number is accepted', () {
      expect(viewModel.validateEmailOrPhone('+1234567890'), null);
    });

    test('Invalid phone number is rejected', () {
      expect(viewModel.validateEmailOrPhone('123456'), isNotNull);
    });

    test('Submit form fails if fields are empty', () async {
      await viewModel.submitForm();
      expect(viewModel.state.isLoading, false);
    });
  });
}
