import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/viewmodel/request_view_model.dart';
import 'package:lockedin/features/networks/viewmodel/suggestion_view_model.dart';
import 'package:lockedin/features/networks/widgets/connect_section.dart';
import 'package:lockedin/features/networks/widgets/follow_section.dart';
import 'package:lockedin/features/networks/widgets/invitation_section.dart';
import 'package:lockedin/features/networks/widgets/manage_network.dart';
import '../viewmodel/company_view_model.dart';
import 'package:provider/provider.dart';

class GrowTab extends StatelessWidget {
  const GrowTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ManageNetwork(),
        Divider(),
        ChangeNotifierProvider(
          create: (_) => RequestViewModel(),
          child: InvitationSection(),
        ),
        Divider(),
        ChangeNotifierProvider(
          create: (_) => SuggestionViewModel(),
          child: ConnectSection(),
        ),
        Divider(),
        ChangeNotifierProvider(
          create: (_) => CompanyViewModel(),
          child: FollowSection(),
        ),
      ],
    );
  }
}
