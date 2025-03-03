import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/widgets/upper_navbar.dart';
import 'package:lockedin/presentation/pages/profile_page.dart';
import '../viewmodels/nav_viewmodel.dart';
import '../pages/home_page.dart';
import '../pages/network_page.dart';
import '../pages/post_page.dart';
import '../pages/notifications_page.dart';
import '../pages/jobs_page.dart';
import '../../core/widgets/bottom_navbar.dart';

class MainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navProvider);

    final List<Widget> pages = [
      HomePage(),
      NetworkPage(),
      PostPage(),
      NotificationsPage(),
      JobsPage(),
    ];

    return Scaffold(
      appBar: UpperNavbar(
        leftIcon: CircleAvatar(
          radius: 20, // Adjust size to match LinkedIn's profile picture
          backgroundColor:
              Colors.transparent, // Ensure no background color interferes
          backgroundImage: AssetImage(
            'assets/images/download.png',
          ), // Your profile image
        ),
        leftOnPress: () {
          (index) => ref.read(navProvider.notifier).changeTab(index);
          ref.read(navProvider.notifier).changeTab(0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(navProvider.notifier).changeTab(index),
      ),
    );
  }
}
