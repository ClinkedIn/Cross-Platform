import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../viewmodel/company_view_model.dart';
import '../widgets/profile_card.dart';

class FollowSection extends StatefulWidget {
  const FollowSection({Key? key}) : super(key: key);

  @override
  State<FollowSection> createState() => _FollowSectionState();
}

class _FollowSectionState extends State<FollowSection> {
  bool _showAllCompanies = false;

  @override
  void initState() {
    super.initState();
    // Fetch companies when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyViewModel>().fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Consumer<CompanyViewModel>(
      builder: (context, viewModel, child) {
        // Handle loading state
        if (viewModel.isLoading) {
          return Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error state
        if (viewModel.hasError) {
          return Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.fetchCompanies(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Handle empty state
        if (viewModel.companies.isEmpty) {
          return Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: const Center(
              child: Text('No companies to follow at this time'),
            ),
          );
        }

        // Determine which companies to show based on the state
        final displayedCompanies =
            _showAllCompanies
                ? viewModel.companies
                : viewModel.companies.take(2).toList();

        final hasMoreCompanies = viewModel.companies.length > 2;

        // Show company list
        return Container(
          color: theme.cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'People in your industry also follow these companies',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Display limited companies using the profile card
              ...displayedCompanies.map((companyResponse) {
                return CompanyProfileCard(
                  company: companyResponse.company,
                  userRelationship: companyResponse.userRelationship,
                  onFollowChanged: (isFollowing) {
                    if (isFollowing) {
                      viewModel.followCompany(companyResponse.company.id);
                    } else {
                      // You can implement unfollow functionality here
                      viewModel.unfollowCompany(companyResponse.company.id);
                    }
                  },
                );
              }).toList(),

              // Show "See more" button if there are more than 2 companies
              if (hasMoreCompanies)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showAllCompanies = !_showAllCompanies;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAllCompanies ? 'Show less' : 'See more',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 16.px,
                          ),
                        ),
                        Icon(
                          _showAllCompanies
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.blue[800],
                          size: 20.px,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
