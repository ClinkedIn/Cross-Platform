import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';

class ProfileCard extends StatelessWidget {
  final String profilePicture;
  final String name;
  final String headline;
  final int mutualConnections;

  const ProfileCard({
    required this.profilePicture,
    required this.name,
    required this.headline,
    required this.mutualConnections,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 30.0,
              backgroundImage: AssetImage(
                profilePicture,
              ), // Replace with image URL
            ),
            SizedBox(width: 16.0),

            // Name, Headline, and Mutual Connections
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    headline,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "$mutualConnections mutual connections",
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Connect Button
            OutlinedButton(
              onPressed: () {},
              style: theme.outlinedButtonTheme.style,
              child: Text('+ Connect', style: TextStyle()),
            ),
          ],
        ),
      ),
    );
  }
}
