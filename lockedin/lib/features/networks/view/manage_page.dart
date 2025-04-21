import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/networks/widgets/manage_button.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Manage my network', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        iconTheme: theme.iconTheme,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            Divider(height: 0),
            ManageButton(
              text: 'Connections',
              icon: Icons.group_add_rounded,
              theme: theme,
              action: () => context.push('/connections'),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Groups',
              icon: Icons.groups,
              theme: theme,
              action: () => context.push('/groups'),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Events',
              icon: Icons.calendar_month,
              theme: theme,
              action: () => context.push('/events'),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Pages',
              icon: Icons.apartment,
              theme: theme,
              action: () => context.push('/pages'),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Newsletters',
              icon: Icons.newspaper,
              theme: theme,
              action: () => context.push('/newsletter'),
            ),
            Divider(height: 0),
          ],
        ),
      ),
    );
  }
}
