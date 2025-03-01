import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/home_viewmodel.dart';
import '../shared/post_list.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body:
          homeState.isLoading
              ? Center(child: CircularProgressIndicator())
              : PostList(posts: homeState.posts),
    );
  }
}
