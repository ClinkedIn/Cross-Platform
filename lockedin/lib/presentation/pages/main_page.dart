import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/widgets/side_bar.dart';
import 'package:lockedin/core/widgets/upper_navbar.dart';
import 'package:lockedin/presentation/pages/profile_page.dart';
import 'package:lockedin/presentation/viewmodels/profile_viewmodel.dart';
import '../viewmodels/nav_viewmodel.dart';
import '../pages/home_page.dart';
import '../pages/network_page.dart';
import '../pages/post_page.dart';
import '../pages/notifications_page.dart';
import '../pages/jobs_page.dart';
import '../../core/widgets/bottom_navbar.dart';

class MainPage extends ConsumerWidget {
  MainPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // 🔥 Add this key

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navProvider);
    final currentUserAsync = ref.watch(profileViewModelProvider);

    final List<Widget> pages = [
      HomePage(),
      NetworkPage(),
      PostPage(),
      NotificationsPage(),
      JobsPage(),
    ];

    return Scaffold(
      key: _scaffoldKey, // 🔥 Attach the key here
      appBar: UpperNavbar(
        leftIcon: currentUserAsync.when(
          data:
              (currentUser) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(currentUser.profilePicture!),
              ),
          loading:
              () => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.white),
              ),
          error:
              (error, stackTrace) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red,
                child: Icon(Icons.error, color: Colors.white),
              ),
        ),

        leftOnPress: () {
          _scaffoldKey.currentState
              ?.openDrawer(); // 🔥 Use key to open drawer safely
        },
      ),
      drawer: SidebarDrawer(),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(navProvider.notifier).changeTab(index),
      ),
    );
  }
}
