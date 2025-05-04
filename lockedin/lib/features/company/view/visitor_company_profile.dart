import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:lockedin/features/company/widgets/post_card.dart';
import 'package:sizer/sizer.dart';

class CompanyVisitorView extends ConsumerStatefulWidget {
  final String companyId;

  const CompanyVisitorView({Key? key, required this.companyId}) : super(key: key);

  @override
  ConsumerState<CompanyVisitorView> createState() => _CompanyVisitorViewState();
}

class _CompanyVisitorViewState extends ConsumerState<CompanyVisitorView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(companyViewModelProvider).fetchCompanyById(widget.companyId);
      ref.read(companyViewModelProvider).fetchCompanyPosts(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(companyViewModelProvider);
    final company = vm.fetchedCompany;
    final posts = vm.companyPosts;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                company?.name ?? 'Company',
                style: TextStyle(fontSize: 20.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (company != null)
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: company.isFollowing ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await ref.read(companyViewModelProvider).toggleFollowCompany(company.id!);
                  setState(() {}); // force UI rebuild to reflect isFollowing state
                },
                child: Text(company.isFollowing ? 'Unfollow' : 'Follow'),
              ),
          ],
        ),
      ),
      body: company == null
              ? Center(child: Text('Company not found'))
              : ListView(
                  padding: EdgeInsets.all(3.w),
                  children: [
                    Text("Company Overview", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 1.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (company.logo != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  company.logo!,
                                  width: double.infinity,
                                  height: 20.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            SizedBox(height: 2.w),
                            Text('Name: ${company.name}', style: TextStyle(fontSize: 17.sp, color: Colors.black)),
                            SizedBox(height: 1.w),
                            Text('Location: ${company.address}', style: TextStyle(fontSize: 17.sp, color: Colors.black)),
                            if (company.website != null)
                              Text('Website: ${company.website}', style: TextStyle(fontSize: 17.sp, color: Colors.black)),
                            Text('Industry: ${company.industry}', style: TextStyle(fontSize: 17.sp, color: Colors.black)),
                            Text('Organization Size: ${company.organizationSize}', style: TextStyle(fontSize: 17.sp, color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text("Recent Posts and Jobs", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 1.h),
                    ...posts.map((post) => PostCard(post: post, companyLogoUrl: company.logo)),
                  ],
                ),
    );
  }
}
