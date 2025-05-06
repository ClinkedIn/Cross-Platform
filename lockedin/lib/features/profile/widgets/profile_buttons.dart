import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';

class ProfileButtons extends StatelessWidget {
  final bool isPremium;

  const ProfileButtons({super.key, this.isPremium = false});
  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => context.push("/add-section"),
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

          if (!isPremium)
            SizedBox(
              width: double.infinity, // Ensures full width
              child: OutlinedButton(
                onPressed: () {
                  context.push("/subscription");
                },
                child: Text("Enhance Profile"),
              ),
            ),
        ],
      ),
    );
  }
}
