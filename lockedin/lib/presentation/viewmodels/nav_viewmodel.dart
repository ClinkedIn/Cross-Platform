import 'package:flutter_riverpod/flutter_riverpod.dart';

final navProvider = StateNotifierProvider<NavViewModel, int>(
  (ref) => NavViewModel(),
);

class NavViewModel extends StateNotifier<int> {
  NavViewModel() : super(0); // Default to Home Tab

  void changeTab(int index) {
    state = index;
  }
}
