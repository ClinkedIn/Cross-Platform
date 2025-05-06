import 'package:flutter/material.dart';

class PasswordValidationIndicators extends StatelessWidget {
  final List<String> validations;

  const PasswordValidationIndicators({Key? key, required this.validations})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            validations.map((validation) {
              final bool isValid = validation.startsWith("✓");
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  validation,
                  style: TextStyle(
                    fontSize: 12,
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class PasswordMatchIndicator extends StatelessWidget {
  final String newPassword;
  final String confirmPassword;

  const PasswordMatchIndicator({
    Key? key,
    required this.newPassword,
    required this.confirmPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool doPasswordsMatch = newPassword == confirmPassword;

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8),
      child: Row(
        children: [
          Icon(
            doPasswordsMatch ? Icons.check_circle : Icons.cancel,
            color: doPasswordsMatch ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            doPasswordsMatch ? "Passwords match" : "Passwords don't match",
            style: TextStyle(
              fontSize: 12,
              color: doPasswordsMatch ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
