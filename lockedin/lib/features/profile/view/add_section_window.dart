import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddToProfilePage extends ConsumerWidget {
  final List<String> coreItems = [
    "education",
    "position",
    "services",
    "career break",
    "skills",
  ];

  final List<String> recommendedItems = [
    "Example recommended item 1",
    "Example recommended item 2",
  ];

  final List<String> additionalItems = [
    "Example additional item 1",
    "Example additional item 2",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Add to profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildExpansionTile(context, 'Core', [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Start with the basics. Filling out these sections will help you be discovered by recruiters and people you may know',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
            ...coreItems.map(
              (item) => Column(
                children: [
                  ListTile(
                    title: Text("Add $item", style: theme.textTheme.bodyLarge),
                    onTap: () {
                      context.push("/add-$item");
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                  ),
                  Divider(color: theme.dividerTheme.color),
                ],
              ),
            ),
          ], theme: theme),
          _buildExpansionTile(
            context,
            'Recommended',
            recommendedItems
                .map(
                  (item) => ListTile(
                    title: Text(item, style: theme.textTheme.bodyLarge),
                    onTap: () {},
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                  ),
                )
                .toList(),
            theme: theme,
          ),
          _buildExpansionTile(
            context,
            'Additional',
            additionalItems
                .map(
                  (item) => ListTile(
                    title: Text(item, style: theme.textTheme.bodyLarge),
                    onTap: () {},
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                  ),
                )
                .toList(),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    String title,
    List<Widget> children, {
    required ThemeData theme,
  }) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        collapsedIconColor: theme.iconTheme.color,
        iconColor: theme.iconTheme.color,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
        initiallyExpanded: title == 'Core', // Core is expanded by default
      ),
    );
  }
}
