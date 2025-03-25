import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';

class ConnectCard extends StatelessWidget {
  final String backgroundImage;
  final String profileImage;
  final String name;
  final String headline;

  const ConnectCard({
    required this.backgroundImage,
    required this.profileImage,
    required this.name,
    required this.headline,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          // Background Image
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Background image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.asset(
                  backgroundImage, // Replace with asset or network image
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Profile Image
              Positioned(
                top: 80, // Adjust position
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: AssetImage(
                      profileImage,
                    ), // Replace with profile image
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 60), // Space below the profile picture
          // Name and Headline
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  headline,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.0),

          // Connect Button
          OutlinedButton(
            onPressed: () {},
            style: theme.outlinedButtonTheme.style,
            child: Text('+ Connect', style: TextStyle()),
          ),

          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
