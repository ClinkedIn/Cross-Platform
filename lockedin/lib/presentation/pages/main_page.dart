import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(navProvider.notifier).changeTab(index),
      ),
    );
  }
}
