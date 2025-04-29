import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ConnectCard extends StatefulWidget {
  final String backgroundImage;
  final ImageProvider profileImage;
  final String name;
  final String headline;
  final VoidCallback onCardTap;
  final VoidCallback onConnectTap;
  final VoidCallback? onCancelTap;
  final bool isPending;

  const ConnectCard({
    required this.backgroundImage,
    required this.profileImage,
    required this.name,
    required this.headline,
    required this.onCardTap,
    required this.onConnectTap,
    this.onCancelTap,
    required this.isPending,
    Key? key,
  }) : super(key: key);

  @override
  State<ConnectCard> createState() => _ConnectCardState();
}

class _ConnectCardState extends State<ConnectCard> {
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
                  widget.backgroundImage,
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
                      backgroundImage: widget.profileImage,
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
                      GestureDetector(
                        onTap: widget.onCardTap,
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        widget.headline,
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

                  // Connect/Pending Button
                  SizedBox(
                    width: double.infinity,
                    height: 3.h, // Fixed smaller height
                    child:
                        widget.isPending
                            ? OutlinedButton(
                              onPressed: widget.onCancelTap,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 0),
                                textStyle: TextStyle(fontSize: 12),
                                foregroundColor: Colors.grey[600],
                                side: BorderSide(color: Colors.grey[300]!),
                              ).merge(theme.outlinedButtonTheme.style),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Pending'),
                                ],
                              ),
                            )
                            : OutlinedButton(
                              onPressed: widget.onConnectTap,
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
