import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/view/connections_page.dart';
import 'package:lockedin/features/networks/view/events_page.dart';
import 'package:lockedin/features/networks/view/groups_page.dart';
import 'package:lockedin/features/networks/view/newsletters_page.dart';
import 'package:lockedin/features/networks/view/pages_page.dart';
import 'package:lockedin/features/networks/widgets/manage_button.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: Icon(Icons.arrow_back),
        // ),
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
              action: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectionsPage()),
              ),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Groups',
              icon: Icons.groups,
              theme: theme,
              action: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupsPage()),
              ),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Events',
              icon: Icons.calendar_month,
              theme: theme,
              action: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventsPage()),
              ),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Pages',
              icon: Icons.apartment,
              theme: theme,
              action: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PagesPage()),
              ),
            ),
            Divider(height: 0),
            ManageButton(
              text: 'Newsletters',
              icon: Icons.newspaper,
              theme: theme,
              action: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsletterPage()),
              ),
            ),
            Divider(height: 0),
          ],
        ),
      ),
    );
  }
}
