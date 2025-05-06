import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/providers/auth_providers.dart';
import 'package:lockedin/features/auth/state/password_state.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class PasswordOptionsSection extends ConsumerWidget {
  const PasswordOptionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordState = ref.watch(passwordStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sign out option
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: CheckboxListTile(
            value: passwordState.requireSignIn,
            title: Text(
              "Sign out from all devices",
              style: AppTextStyles.bodyText2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "All devices will be required to sign in with your new password",
              style: AppTextStyles.bodyText2.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            onChanged:
                (_) =>
                    ref
                        .read(passwordStateProvider.notifier)
                        .toggleRequireSignIn(),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Error message display
        if (passwordState.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passwordState.errorMessage,
                      style: AppTextStyles.bodyText1.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Status message display
        if (passwordState.statusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passwordState.statusMessage,
                      style: AppTextStyles.bodyText1.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
