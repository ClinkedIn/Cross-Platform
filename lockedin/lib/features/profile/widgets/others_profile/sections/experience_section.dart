import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/utils/profile_converters.dart';
import '../shared/section_container.dart';

class ExperienceSection extends StatefulWidget {
  final List<WorkExperience> experiences;

  const ExperienceSection({Key? key, required this.experiences})
    : super(key: key);

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  bool _showAllExperience = false;

  @override
  Widget build(BuildContext context) {
    if (widget.experiences.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayedItems =
        _showAllExperience
            ? widget.experiences
            : widget.experiences.take(3).toList();

    return SectionContainer(
      title: 'Experience',
      icon: Icons.work,
      child: Column(
        children: [
          ...displayedItems.map((exp) => ExperienceItem(experience: exp)),
          if (widget.experiences.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllExperience = !_showAllExperience;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showAllExperience
                          ? 'Show Less'
                          : 'Show ${widget.experiences.length - 3} More',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _showAllExperience
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ExperienceItem extends StatelessWidget {
  final WorkExperience experience;

  const ExperienceItem({Key? key, required this.experience}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration =
        "${ProfileConverters.formatDate(experience.fromDate)} - ${experience.toDate != null ? ProfileConverters.formatDate(experience.toDate) : 'Present'}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child:
                experience.media != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        experience.media!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.business, color: Colors.grey),
                      ),
                    )
                    : const Icon(Icons.business, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Experience details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.jobTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${experience.companyName} • ${experience.employmentType}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  duration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                if (experience.description != null &&
                    experience.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      experience.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
