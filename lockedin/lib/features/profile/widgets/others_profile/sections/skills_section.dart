import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import '../shared/section_container.dart';

class SkillsSection extends StatelessWidget {
  final UserModel user;

  const SkillsSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (user.about?.skills == null || user.about!.skills.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionContainer(
      title: 'Skills',
      icon: Icons.lightbulb,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              user.about!.skills
                  .map((skill) => _buildSkillChip(skill, theme))
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill, ThemeData theme) {
    return Chip(
      label: Text(skill),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      labelStyle: TextStyle(color: theme.colorScheme.primary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
