import 'package:flutter/material.dart';

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
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Top portion with background and profile
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Background image - reduced height
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.asset(
                  backgroundImage,
                  height: 80, // Reduced height
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Profile image - smaller and less overlap
              Positioned(
                top: 50, // Less overlap with the background
                right: 0,
                left: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 30, // Smaller avatar
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(profileImage),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Compact content area
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                8.0,
                35.0,
                8.0,
                4.0,
              ), // Top padding for profile image
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name and headline in condensed format
                  Column(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        headline,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Connect Button
                  SizedBox(
                    width: double.infinity,
                    height: 35, // Fixed smaller height
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        textStyle: TextStyle(fontSize: 12),
                      ).merge(theme.outlinedButtonTheme.style),
                      child: Text('+ Connect'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
