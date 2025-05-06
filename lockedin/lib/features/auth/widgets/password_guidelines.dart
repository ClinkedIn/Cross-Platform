import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/providers/auth_providers.dart';
import 'package:lockedin/features/auth/state/password_visibility_state.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class PasswordGuidelinesSection extends ConsumerWidget {
  const PasswordGuidelinesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibilityState = ref.watch(passwordVisibilityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: ref.read(passwordVisibilityProvider.notifier).toggleGuidelines,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Password Requirements",
                  style: AppTextStyles.headline2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  visibilityState.showPasswordGuidelines
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (visibilityState.showPasswordGuidelines)
          _buildGuidelinesContent(context),
      ],
    );
  }

  Widget _buildGuidelinesContent(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Strong Password Guidelines",
                  style: AppTextStyles.headline2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRequirementItem(
              "At least 8 characters long",
              Icons.check_circle_outline,
            ),
            _buildRequirementItem(
              "At least one uppercase letter (A-Z)",
              Icons.check_circle_outline,
            ),
            _buildRequirementItem(
              "At least one lowercase letter (a-z)",
              Icons.check_circle_outline,
            ),
            _buildRequirementItem(
              "At least one number (0-9)",
              Icons.check_circle_outline,
            ),
            _buildRequirementItem(
              "At least one special character (!@#\$%^&*)",
              Icons.check_circle_outline,
            ),
            _buildRequirementItem(
              "Avoid using personal information",
              Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodyText1)),
        ],
      ),
    );
  }
}
