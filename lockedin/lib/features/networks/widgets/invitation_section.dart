import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/invitation_card.dart';

class InvitationSection extends StatelessWidget {
  const InvitationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      color: theme.cardColor, // Match LinkedIn dark theme background
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Invitations (19)", style: theme.textTheme.bodyLarge),
              Icon(Icons.arrow_forward, color: theme.iconTheme.color),
            ],
          ),

          const SizedBox(height: 7),
          Divider(),
          SizedBox(
            height: 200, // Adjust this based on card height
            child: ListView(
              physics:
                  NeverScrollableScrollPhysics(), // Disable scrolling inside
              children: const [
                InvitationCard(
                  name: "Omar Fawzi",
                  role: "Senior-2 Electrical Engineer",
                  mutualConnections: "30 mutual connections",
                  timeAgo: "Yesterday",
                  profileImage: "assets/images/default_profile_photo.png",
                ),
                InvitationCard(
                  name: "Amera Yosef",
                  role: "Student at Texas A&M University",
                  mutualConnections: "3 mutual connections",
                  timeAgo: "3 days ago",
                  profileImage: "assets/images/default_profile_photo.png",
                  isOpenToWork: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
