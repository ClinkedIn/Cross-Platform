import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/presentation/viewmodels/sign_up_viewmodel.dart';

class SignUpView extends ConsumerStatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  int _currentStep = 1;
  double _progress = 0.3;
  bool _isPasswordVisible = false;
  //bool _rememberMe = false;

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
    final viewModel = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'LockedIn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 116, 114, 114),
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 116, 114, 114),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_currentStep == 1)
              _buildNameStep(viewModel, notifier)
            else if (_currentStep == 2)
              _buildEmailStep(viewModel, notifier)
            else if (_currentStep == 3)
              _buildPasswordStep(viewModel, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep(SignupState viewModel, SignupViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add your name',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First name*',
            labelStyle: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 116, 114, 114),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last name*',
            labelStyle: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 116, 114, 114),
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildContinueButton(
          _firstNameController.text.isNotEmpty &&
              _lastNameController.text.isNotEmpty,
          () => _goToNextStep(notifier),
        ),
      ],
    );
  }

  Widget _buildEmailStep(SignupState viewModel, SignupViewModel notifier) {
    String? errorText;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(
                begin: 200,
                end: 0,
              ), // Move from right to left
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(value, 0), // Animate the horizontal position
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email or Phone*',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 116, 114, 114),
                      ),
                      errorText: errorText,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Continue Button Animation (Moves from Bottom to Up)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 50, end: 0), // Start from 100px below
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, value), // Move vertically from bottom to up
                  child: _buildContinueButton(
                    _emailController.text.isNotEmpty,
                    () {
                      final validationMessage = notifier.validateEmailOrPhone(
                        _emailController.text,
                      );
                      if (validationMessage != null) {
                        setState(() {
                          errorText = validationMessage;
                        });
                      } else {
                        setState(() {
                          errorText = null;
                        });
                        _goToNextStep(notifier);
                      }
                    },
                  ),
                );
              },
            ),

            _buildBackButton(),
          ],
        );
      },
    );
  }

  Widget _buildPasswordStep(SignupState viewModel, SignupViewModel notifier) {
    String? emailErrorText;
    String? passwordErrorText;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email TextField with validation
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email or Phone*',
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 116, 114, 114),
                ),
                errorText: emailErrorText,
              ),
              onChanged: (value) {
                final validationMessage = notifier.validateEmailOrPhone(value);
                setState(() {
                  emailErrorText = validationMessage;
                });
              },
            ),
            const SizedBox(height: 15),

            // 🔥 Animated Password TextField (Right to Left)
            TweenAnimationBuilder(
              tween: Tween<double>(
                begin: 200,
                end: 0,
              ), // Start 200px from right
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(value, 0), // Move horizontally
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password*',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 116, 114, 114),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      errorText: passwordErrorText,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            const Text(
              "Password must be 6+ characters",
              style: TextStyle(color: Color.fromARGB(255, 116, 114, 114)),
            ),

            const SizedBox(height: 8),

            // Remember Me Checkbox
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Checkbox(
                      visualDensity: VisualDensity.compact,
                      activeColor: Colors.black,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: viewModel.rememberMe,
                      onChanged: (bool? value) {
                        if (value != null) {
                          notifier.setRememberMe(value);
                        }
                      },
                    ),
                  ),
                  const Text("Remember me"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildContinueButton(
              _passwordController.text.length >= 6,
              () async {
                final emailValidation = notifier.validateEmailOrPhone(
                  _emailController.text,
                );
                if (emailValidation != null) {
                  setState(() {
                    emailErrorText = emailValidation;
                  });
                  return;
                }

                setState(() {
                  emailErrorText = null;
                });

                if (_passwordController.text.length < 6) {
                  setState(() {
                    passwordErrorText =
                        "Password must be at least 6 characters";
                  });
                  return;
                } else {
                  setState(() {
                    passwordErrorText = null;
                  });
                }

                print("🚀 Submit button clicked");
                notifier.setPassword(_passwordController.text);
                await notifier.submitForm();
              },
            ),

            _buildBackButton(),
          ],
        );
      },
    );
  }

  Widget _buildContinueButton(bool isEnabled, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: _goBack,
      child: const Text(
        'Back',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
