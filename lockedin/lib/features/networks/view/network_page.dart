import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/view/grow_tab.dart';
import 'package:lockedin/features/networks/view/catch_up_tab.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';
import 'package:lockedin/features/networks/widgets/profile_card.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';

class NetworksPage extends StatefulWidget {
  @override
  _NetworksPageState createState() => _NetworksPageState();
}

class _NetworksPageState extends State<NetworksPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: theme.appBarTheme.elevation,
          toolbarHeight: 40, // Reduced height
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10), // Adjusted height
            child: TabBar(
              labelColor: theme.tabBarTheme.labelColor,
              unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor,
              indicator: theme.tabBarTheme.indicator,
              labelStyle: theme.textTheme.labelLarge,
              tabs: [Tab(text: 'Grow'), Tab(text: 'Catch up')],
            ),
          ),
        ),
        body: TabBarView(children: [GrowTab(), CatchUpPage()]),
      ),
    );
  }
}
