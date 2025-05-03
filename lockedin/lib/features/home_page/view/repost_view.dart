import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/home_page/viewModel/repost_viewmodel.dart';
import 'package:lockedin/features/home_page/state/repost_state.dart';
import 'package:lockedin/features/post/widgets/post_list.dart';
import 'package:lockedin/shared/theme/colors.dart';

class RepostPage extends ConsumerStatefulWidget {
  final String postId;
  
  const RepostPage({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<RepostPage> createState() => _RepostPageState();
}

class _RepostPageState extends ConsumerState<RepostPage> {
  @override
  void initState() {
    super.initState();
    // Load reposts when page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(repostViewModelProvider(widget.postId)).loadReposts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repostState = ref.watch(repostStateProvider(widget.postId));
    final viewModel = ref.watch(repostViewModelProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Reposts'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: repostState.isLoading && repostState.posts.isEmpty
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : repostState.error != null
              ? _buildErrorView(context, repostState.error!, viewModel)
              : repostState.posts.isEmpty
                  ? _buildEmptyView(context)
                  : RefreshIndicator(
                      onRefresh: () async {
                        await viewModel.refreshReposts();
                      },
                      child: PostList(
                        posts: repostState.posts,
                        isLoadingMore: repostState.isLoading && repostState.posts.isNotEmpty,
                        hasMorePages: repostState.pagination['hasNextPage'] == true,
                      ),
                    ),
    );
  }

  Widget _buildErrorView(
    BuildContext context, 
    String error, 
    RepostViewModel viewModel
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 15.h, color: Colors.red),
          SizedBox(height: 2.h),
          Text(
            'Error loading reposts',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: Colors.red,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: Colors.red,
                ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              viewModel.refreshReposts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat, size: 15.h, color: AppColors.gray),
          SizedBox(height: 2.h),
          Text(
            'No reposts',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.gray,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This post has not been reposted yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.gray,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}