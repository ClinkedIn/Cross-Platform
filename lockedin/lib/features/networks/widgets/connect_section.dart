import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';
import 'package:lockedin/features/networks/widgets/connect_grid.dart';
import 'package:lockedin/features/networks/widgets/invitation_card.dart';
import 'package:lockedin/features/networks/widgets/profile_card.dart';

class ConnectSection extends StatelessWidget {
  const ConnectSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('More suggestions for you', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          ConnectCardsGridView(
            connectCards: [
              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 1',
                headline: 'Test 1',
              ),

              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 2',
                headline: 'Test 2',
              ),

              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 3',
                headline: 'Test 3',
              ),

              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 4',
                headline: 'Test 4',
              ),
              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 5',
                headline: 'Test 5',
              ),

              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 6',
                headline: 'Test 6',
              ),

              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 7',
                headline: 'Test 7',
              ),

              ConnectCard(
                backgroundImage: 'assets/images/default_cover_photo.jpeg',
                profileImage: 'assets/images/default_profile_photo.png',
                name: 'User 8',
                headline: 'Test 8',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
