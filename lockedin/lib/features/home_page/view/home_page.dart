import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/routing.dart';
import 'package:sizer/sizer.dart';
import '../viewModel/home_viewmodel.dart';
import '../../profile/widgets/post_list.dart';
import 'package:lockedin/shared/theme/colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(userDataLoadedProvider)) {
        ref.read(profileViewModelProvider).fetchUser(context);
        ref.read(userDataLoadedProvider.notifier).state = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body:
          homeState.isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : homeState.error != null
              ? _buildErrorView(context, homeState.error!, ref)
              : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(homeViewModelProvider.notifier).refreshFeed();
                },
                child: PostList(posts: homeState.posts),
              ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 15.h, color: Colors.red),
          SizedBox(height: 2.h),
          Text(
            'Error loading posts',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).refreshFeed();
            },
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            ),
          ),
        ],
      ),
    );
  }
}
