import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? profilePictureUrl;
  final double size;
  final double topPosition;

  const ProfilePicture({
    Key? key,
    required this.profilePictureUrl,
    this.size = 200,
    this.topPosition = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child:
                profilePictureUrl != null
                    ? Image.network(
                      profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: size * 0.5,
                              color: Colors.grey[600],
                            ),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: Colors.grey[600],
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
