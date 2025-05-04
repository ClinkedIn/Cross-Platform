import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lockedin/features/networks/viewmodel/request_view_model.dart';
import 'package:lockedin/features/networks/widgets/invitation_card.dart';
import 'package:go_router/go_router.dart';

class InvitationSection extends StatefulWidget {
  const InvitationSection({Key? key}) : super(key: key);

  @override
  State<InvitationSection> createState() => _InvitationSectionState();
}

class _InvitationSectionState extends State<InvitationSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestViewModel>(context, listen: false).fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Consumer<RequestViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          color: theme.cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with dynamic count from ViewModel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Invitations (${viewModel.requestCount})",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.start,
                  ),
                  InkWell(
                    onTap: () {
                      context.push('/invitations');
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),
              Divider(),

              // Show different UI based on the ViewModel state
              _buildInvitationsContent(viewModel, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvitationsContent(RequestViewModel viewModel, ThemeData theme) {
    switch (viewModel.state) {
      case RequestViewState.loading:
        return SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );

      case RequestViewState.error:
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Could not load invitations'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => viewModel.fetchRequests(),
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Color(0xFF006097)),
                  ),
                ),
              ],
            ),
          ),
        );

      case RequestViewState.loaded:
        if (viewModel.requestCount == 0) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('No invitations')),
          );
        }

        final int itemsToShow =
            viewModel.requestCount > 2 ? 2 : viewModel.requestCount;
        final double cardHeight = 100; // Approximate height of each card

        return SizedBox(
          // Height calculation: number of cards × height per card
          height: itemsToShow * cardHeight,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: itemsToShow,
            itemBuilder: (context, index) {
              final request = viewModel.requests[index];

              return InvitationCard(
                name: "${request.firstName} ${request.lastName}",
                role: request.headline ?? "No headline",
                mutualConnections:
                    "Connect", // You may need to add this to your model
                timeAgo: "Recently", // You may need to add this to your model
                profileImage:
                    request.profilePicture.startsWith('assets/')
                        ? request.profilePicture
                        : "assets/images/default_profile_photo.png", // Fallback for network images
                isOpenToWork: false, // You may need to add this to your model
                onAccept: () => _handleAccept(request.id, viewModel),
                onDecline: () => _handleDecline(request.id, viewModel),
                onNameTap: () => _handleNameTap(request.id),
              );
            },
          ),
        );

      case RequestViewState.initial:
      default:
        return SizedBox(height: 200);
    }
  }

  // Handle accept action
  Future<void> _handleAccept(
    String requestId,
    RequestViewModel viewModel,
  ) async {
    try {
      await viewModel.acceptRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation accepted'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept invitation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle decline action
  Future<void> _handleDecline(
    String requestId,
    RequestViewModel viewModel,
  ) async {
    try {
      await viewModel.declineRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation declined'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline invitation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNameTap(String userID) {
    context.pushNamed('other-profile', pathParameters: {'userId': userID});
  }
}
