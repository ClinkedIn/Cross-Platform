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
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(editEmailViewModelProvider);

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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                          if (viewModel.apiMessage ==
                              "Email updated successfully") {
                            Navigator.pop(context, emailController.text);
                          }
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
