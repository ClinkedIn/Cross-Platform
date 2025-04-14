import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/repository/edit_email_repository.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/features/auth/viewmodel/edit_email_viewmodel.dart';

final editEmailViewModelProvider = ChangeNotifierProvider(
  (ref) => EditEmailViewModel(ref.read(editEmailRepositoryProvider)),
);

class EditEmailView extends ConsumerStatefulWidget {
  const EditEmailView({super.key});

  @override
  _EditEmailViewState createState() => _EditEmailViewState();
}

class _EditEmailViewState extends ConsumerState<EditEmailView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Reset any existing messages when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(editEmailViewModelProvider).resetMessages();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Show a snackbar with the appropriate styling based on success/error
  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: isSuccess ? 3 : 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        action:
            isSuccess
                ? null
                : SnackBarAction(
                  label: 'DISMISS',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(editEmailViewModelProvider);

    // Listen for changes in the apiMessage
    ref.listen<EditEmailViewModel>(editEmailViewModelProvider, (
      previous,
      current,
    ) {
      if (previous?.apiMessage != current.apiMessage &&
          current.apiMessage != null) {
        final isSuccess = current.apiMessage == "Email updated successfully";

        // Show the appropriate snackbar
        _showSnackBar(current.apiMessage!, isSuccess);

        // If successful, navigate back after a short delay
        if (isSuccess) {
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context, emailController.text);
            }
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Email")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "New Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: viewModel.emailError,
              ),
              onChanged: viewModel.validateEmailOrPhone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (viewModel.isLoading) const CircularProgressIndicator(),

            if (viewModel.apiMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      viewModel.apiMessage!.contains("success")
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        viewModel.apiMessage!.contains("success")
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      viewModel.apiMessage!.contains("success")
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color:
                          viewModel.apiMessage!.contains("success")
                              ? Colors.green
                              : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.apiMessage!,
                        style: TextStyle(
                          color:
                              viewModel.apiMessage!.contains("success")
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    viewModel.isEmailValid && !viewModel.isLoading
                        ? () async {
                          await ref
                              .read(editEmailViewModelProvider)
                              .updateEmail(
                                emailController.text,
                                passwordController.text,
                              );
                          // Navigation is now handled by the listener
                        }
                        : null,
                style: AppButtonStyles.elevatedButton,
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
