import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/profile/state/user_state.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
      _fetchUserProfile();
    });
  }

  Future<void> _checkAuthentication() async {
    if (!mounted) return;

    final hasCookie = await TokenService.hasCookie();

    if (!hasCookie) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  void _fetchUserProfile() {
    if (!mounted) return;
    ref.read(profileViewModelProvider).fetchUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navProvider);
    final currentUser = ref.watch(userProvider);

    // Just in case currentUser is still null
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        leftIcon: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(currentUser.profilePicture),
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
