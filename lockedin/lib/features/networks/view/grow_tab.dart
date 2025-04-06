import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/connect_section.dart';
import 'package:lockedin/features/networks/widgets/follow_section.dart';
import 'package:lockedin/features/networks/widgets/invitation_section.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';

class GrowTab extends StatelessWidget {
  const GrowTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      children: [
        InvitationSection(),
        Divider(),
        ConnectSection(),
        Divider(),
        FollowSection(),
      ],
    );
  }
}
