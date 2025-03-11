import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:lockedin/presentation/viewmodels/verification_email_viewmodel.dart';

final verificationEmailViewModelProvider = ChangeNotifierProvider(
  (ref) => VerificationEmailViewModel(),
);

class VerificationEmailView extends ConsumerStatefulWidget {
  final String email;
  const VerificationEmailView({super.key, required this.email});
  @override
  _VerificationEmailViewState createState() => _VerificationEmailViewState();
}

class _VerificationEmailViewState extends ConsumerState<VerificationEmailView> {
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the verification code when the screen loads
    Future.microtask(
      () =>
          ref.read(verificationEmailViewModelProvider).fetchVerificationCode(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(verificationEmailViewModelProvider);
    final signupState = ref.watch(signupProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header Section
              const Text(
                'LockedIn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Enter the verification code",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 🔹 Email Info & Edit Option
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 116, 114, 114),
                  ),
                  children: [
                    TextSpan(
                      text:
                          "We sent the verification code to   ${widget.email}  ",
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                            true,
                          ); // Send 'true' to indicate email edit
                        }, // Navigate back to edit email

                        child: const Text(
                          "Edit email",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Display the received verification code (For Debugging - REMOVE in Production)
              Text(
                "Received Code: ${viewModel.receivedCode}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 10),

              // 🔹 Verification Code Input
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "6-digit code*",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(verificationEmailViewModelProvider)
                      .updateCode(value);
                },
              ),

              const Spacer(),

              // 🔹 Buttons (Next & Resend)
              Column(
                children: [
                  ElevatedButton(
                    onPressed:
                        viewModel.isCodeValid
                            ? () {
                              viewModel.verifyCode(context);
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed:
                        viewModel.isResendDisabled
                            ? null // Disable button when resend is in cooldown
                            : () => viewModel.resendCode(),
                    child: Text(
                      viewModel.isResendDisabled ? "Wait..." : "Resend code",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
