import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/profile_card.dart';

class FollowSection extends StatelessWidget {
  const FollowSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'People who are also in the Software Development industry also follow these people',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          ProfileCard(
            name: 'Osama Elzero',
            headline: 'Ys',
            profileImage: 'assets/images/default_profile_photo.png',
            backgroundImage: 'default_cover_photo.jpeg',
            onFollowChanged: (p0) {},
          ),
          SizedBox(height: 10),

          ProfileCard(
            name: 'Mostafa Saad Ibrahim',
            headline:
                'PhD | Senior Computer Vision Engineer / Applied Scientist',
            profileImage: 'assets/images/default_profile_photo.png',
            backgroundImage: 'default_cover_photo.jpeg',
            onFollowChanged: (p0) {},
          ),
        ],
      ),
    );
  }
}
