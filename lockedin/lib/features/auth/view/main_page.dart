import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/shared/widgets/side_bar.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';
import 'package:lockedin/features/home_page/view/home_page.dart';
import 'package:lockedin/features/networks/view/network_page.dart';
import 'package:lockedin/features/post/view/post_page.dart';
import 'package:lockedin/features/notifications/view/notifications_page.dart';
import 'package:lockedin/features/jobs/view/jobs_page.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';

class MainPage extends ConsumerStatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (await TokenService.hasToken() == false) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navProvider);
    final currentUserAsync = ref.watch(profileViewModelProvider);

    final List<Widget> pages = [
      HomePage(),
      NetworksPage(),
      PostPage(),
      NotificationsPage(),
      JobsPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: UpperNavbar(
        leftIcon: currentUserAsync.when(
          data:
              (currentUser) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(currentUser.profilePicture),
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
          _scaffoldKey.currentState?.openDrawer();
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
