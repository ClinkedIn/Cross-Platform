import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex == -1 ? 0 : currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Network'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
      ],
    );
  }
}

final navProvider = StateNotifierProvider<NavViewModel, int>(
  (ref) => NavViewModel(),
);

class NavViewModel extends StateNotifier<int> {
  NavViewModel() : super(0); // Default to Home Tab

  void changeTab(int index) {
    state = index;
  }
}
