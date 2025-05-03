import 'package:flutter/material.dart';

class InvitationCard extends StatelessWidget {
  final String name;
  final String role;
  final String mutualConnections;
  final String timeAgo;
  final String profileImage;
  final bool isOpenToWork;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onNameTap;

  const InvitationCard({
    Key? key,
    required this.name,
    required this.role,
    required this.mutualConnections,
    required this.timeAgo,
    this.profileImage = "/assets/images/default_profile_photo.png",
    this.isOpenToWork = false,
    required this.onAccept,
    required this.onDecline,
    required this.onNameTap,
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
          CircleAvatar(
            backgroundImage:
                profileImage.startsWith('http')
                    ? NetworkImage(profileImage) as ImageProvider
                    : AssetImage(profileImage),
            radius: 24,
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback for failed image loads
            },
          ),
          SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Text(name, style: theme.textTheme.bodyLarge),
                  onTap: onNameTap,
                ),
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
                if (isOpenToWork)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#OpenToWork',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: onDecline,
                icon: Icon(Icons.close, color: Colors.grey[400]),
              ),
              IconButton(
                onPressed: onAccept,
                icon: Icon(Icons.check, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
