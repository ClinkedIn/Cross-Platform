import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/utils/profile_converters.dart';
import '../shared/section_container.dart';

class EducationSection extends StatefulWidget {
  final List<Education> educations;

  const EducationSection({Key? key, required this.educations})
    : super(key: key);

  @override
  State<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  bool _showAllEducation = false;

  @override
  Widget build(BuildContext context) {
    if (widget.educations.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayedItems =
        _showAllEducation
            ? widget.educations
            : widget.educations.take(3).toList();

    return SectionContainer(
      title: 'Education',
      icon: Icons.school,
      child: Column(
        children: [
          ...displayedItems.map((edu) => EducationItem(education: edu)),
          if (widget.educations.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllEducation = !_showAllEducation;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showAllEducation
                          ? 'Show Less'
                          : 'Show ${widget.educations.length - 3} More',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _showAllEducation
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

class EducationItem extends StatelessWidget {
  final Education education;

  const EducationItem({Key? key, required this.education}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration =
        education.startDate != null
            ? "${ProfileConverters.formatDate(education.startDate)} - ${education.endDate != null ? ProfileConverters.formatDate(education.endDate) : 'Present'}"
            : "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child:
                education.media != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        education.media!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.school, color: Colors.grey),
                      ),
                    )
                    : const Icon(Icons.school, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Education details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education.school,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                if (education.degree != null)
                  Text(
                    '${education.degree} ${education.fieldOfStudy != null ? '• ${education.fieldOfStudy}' : ''}',
                    style: theme.textTheme.bodyMedium,
                  ),
                const SizedBox(height: 2),
                if (duration.isNotEmpty)
                  Text(
                    duration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                if (education.description != null &&
                    education.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      education.description!,
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
