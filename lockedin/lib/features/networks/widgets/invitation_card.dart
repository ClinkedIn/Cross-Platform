import 'package:flutter/material.dart';

class InvitationCard extends StatelessWidget {
  final String name;
  final String role;
  final String mutualConnections;
  final String timeAgo;
  final String profileImage;
  final bool isOpenToWork;

  const InvitationCard({
    Key? key,
    required this.name,
    required this.role,
    required this.mutualConnections,
    required this.timeAgo,
    required this.profileImage,
    this.isOpenToWork = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(backgroundImage: AssetImage(profileImage), radius: 24),
          SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.labelLarge),
                Text(
                  role,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(mutualConnections, style: theme.textTheme.bodySmall),
                Text(
                  timeAgo,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.close, color: Colors.grey[400]),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.check, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
