import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';

class ProfileButtons extends StatelessWidget {
  const ProfileButtons({super.key});
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colorScheme = AppColors();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(onPressed: () {}, child: Text("Open to")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text("Add section"),
                ),
              ),
              SizedBox(width: 10),
              AppButtonStyles.outlinedIconButton(
                onPressed: () {},
                icon: Icons.more_horiz,
              ),
            ],
          ),
          SizedBox(height: 10),

          // Full-width OutlinedButton
          SizedBox(
            width: double.infinity, // Ensures full width
            child: OutlinedButton(
              onPressed: () {},
              child: Text("Enhance Profile"),
            ),
          ),
        ],
      ),
    );
  }
}
