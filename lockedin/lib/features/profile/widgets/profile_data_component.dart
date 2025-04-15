import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/model/profile_item_model.dart';
import 'package:lockedin/features/profile/widgets/profile_component.dart';

class ProfileDataComponent extends ConsumerStatefulWidget {
  final String sectionTitle;
  final String addRoute;
  final String editRoute;
  final AsyncValue<List<dynamic>> dataProvider;
  final ProfileItemModel Function(dynamic) itemConverter;

  const ProfileDataComponent({
    Key? key,
    required this.sectionTitle,
    required this.addRoute,
    required this.editRoute,
    required this.dataProvider,
    required this.itemConverter,
  }) : super(key: key);

  @override
  ConsumerState<ProfileDataComponent> createState() =>
      _ProfileDataComponentState();
}

class _ProfileDataComponentState extends ConsumerState<ProfileDataComponent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return widget.dataProvider.when(
      data: (items) {
        // Handle empty data case
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sectionTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text("No data to display"),
                TextButton(
                  onPressed: () => context.push(widget.addRoute),
                  child: Text("Add ${widget.sectionTitle}"),
                ),
              ],
            ),
          );
        }

        final profileItems = items.map(widget.itemConverter).toList();

        // Determine how many items to show
        final itemsToShow =
            _expanded ? profileItems : profileItems.take(2).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              ProfileComponent(
                sectionTitle: widget.sectionTitle,
                items: itemsToShow,
                onAdd: () => context.push(widget.addRoute),
                onEdit:
                    profileItems.isNotEmpty
                        ? () => context.push(widget.editRoute)
                        : () {},
              ),
              if (profileItems.length > 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      icon: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      label: Text(_expanded ? 'Hide' : 'View more'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Text("Error: ${error.toString()}"),
    );
  }
}
