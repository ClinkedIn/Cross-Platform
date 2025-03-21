import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/features/auth/viewmodel/edit_email_viewmodel.dart';

final editEmailViewModelProvider = ChangeNotifierProvider(
  (ref) => EditEmailViewModel(),
);

class EditEmailView extends ConsumerStatefulWidget {
  final String initialEmail;

  const EditEmailView({super.key, required this.initialEmail});

  @override
  _EditEmailViewState createState() => _EditEmailViewState();
}

class _EditEmailViewState extends ConsumerState<EditEmailView> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    emailController.dispose();
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
              onChanged: viewModel.validateEmail,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    viewModel.isEmailValid
                        ? () {
                          Navigator.pop(context, emailController.text);
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
