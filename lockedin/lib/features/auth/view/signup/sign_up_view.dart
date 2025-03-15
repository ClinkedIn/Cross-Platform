import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/verification_email_view.dart';
import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/features/auth/view/signup/name_step.dart';
import 'package:lockedin/features/auth/view/signup/password_step.dart';
import 'package:lockedin/features/auth/view/signup/email_step.dart';

class SignUpView extends ConsumerStatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  int _currentStep = 1;
  double _progress = 0.3;
  bool rememberMe = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_updateState);
    _lastNameController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  void _goToNextStep(SignupViewModel notifier) {
    setState(() {
      if (_currentStep == 1) {
        notifier.setFirstName(_firstNameController.text);
        notifier.setLastName(_lastNameController.text);
        _progress = 0.6;
      } else if (_currentStep == 2) {
        notifier.setEmail(_emailController.text);
        _progress = 0.9;
      }
      _currentStep++;
    });
  }

  void _goBack() {
    setState(() {
      if (_currentStep == 2) {
        _progress = 0.3;
      } else if (_currentStep == 3) {
        _progress = 0.6;
      }
      _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final viewModel = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    ref.listen(signupProvider, (previous, next) async {
      if (next.success) {
        print("✅ Navigation Triggered with Email: ${next.email}");

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationEmailView(email: next.email),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Locked ",
              style: AppTextStyles.headline1.copyWith(color: AppColors.primary),
            ),
            Image.network(
              "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
              height: 30,
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Create account', style: theme.textTheme.bodyLarge),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (viewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_currentStep == 1)
                  NameStep(
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    notifier: notifier,
                    onNextStep: () => _goToNextStep(notifier),
                  )
                else if (_currentStep == 2)
                  EmailStep(
                    emailController: _emailController,
                    notifier: notifier,
                    onNextStep: () => _goToNextStep(notifier),
                    onBack: _goBack,
                  )
                else if (_currentStep == 3)
                  PasswordStep(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    viewModel: viewModel,
                    notifier: notifier,
                    onBack: _goBack,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
