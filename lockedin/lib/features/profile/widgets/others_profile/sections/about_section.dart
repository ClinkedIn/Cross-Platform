import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import '../shared/section_container.dart';

class AboutSection extends StatelessWidget {
  final UserModel user;

  const AboutSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (user.about?.description == null) {
      return const SizedBox.shrink();
    }

    return SectionContainer(
      title: 'About',
      icon: Icons.person,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(user.about!.description!, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
