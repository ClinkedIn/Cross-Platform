import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';
import 'package:lockedin/features/networks/widgets/profile_card.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';

class NetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              ConnectCard(
                backgroundImage: 'assets/images/download.jpeg',
                profileImage: 'assets/images/download.png',
                name: 'Mohamed AlKhateeb',
                headline: 'Goofball',
              ),
              ProfileCard(
                profilePicture: 'assets/images/download.png',
                name: 'Mohamed AlKhateeb',
                headline: 'Goofball',
                mutualConnections: 500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
