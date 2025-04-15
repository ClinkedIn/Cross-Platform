import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/networks/model/request_list_model.dart';
import 'package:lockedin/features/networks/viewmodel/request_view_model.dart';
import 'package:lockedin/features/networks/widgets/invitation_card.dart';

// Create a provider for the RequestViewModel
final requestViewModelProvider = ChangeNotifierProvider<RequestViewModel>((
  ref,
) {
  return RequestViewModel();
});

class InvitationPage extends ConsumerStatefulWidget {
  const InvitationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends ConsumerState<InvitationPage> {
  @override
  void initState() {
    super.initState();
    // Fetch requests when the page is initialized
    Future.microtask(() => ref.read(requestViewModelProvider).fetchRequests());
  }

  @override
  Widget build(BuildContext context) {
    // Watch the view model
    final viewModel = ref.watch(requestViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        // Include the count in the title
        title: Text(
          viewModel.state == RequestViewState.loaded
              ? 'Invitations (${viewModel.requestCount})'
              : 'Invitations',
        ),
        elevation: 1,
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(RequestViewModel viewModel) {
    switch (viewModel.state) {
      case RequestViewState.loading:
        return const Center(child: CircularProgressIndicator());

      case RequestViewState.loaded:
        return _buildRequestList(viewModel);

      case RequestViewState.error:
        return _buildErrorState(viewModel);

      case RequestViewState.initial:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRequestList(RequestViewModel viewModel) {
    if (viewModel.requestCount == 0) {
      return const Center(child: Text('No pending invitations'));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchRequests(),
      child: ListView.builder(
        itemCount: viewModel.requestCount,
        itemBuilder: (context, index) {
          final request = viewModel.requests[index];
          return _buildInvitationCard(request);
        },
      ),
    );
  }

  Widget _buildInvitationCard(Request request) {
    // Map the Request model to the InvitationCard parameters
    return InvitationCard(
      name: '${request.firstName} ${request.lastName}',
      role: request.headline,
      mutualConnections: '• Mutual connections', // Placeholder
      timeAgo: '• Just now', // Placeholder
      profileImage:
          request.profilePicture.isNotEmpty
              ? request.profilePicture
              : 'assets/images/default_profile.png',
      isOpenToWork: false, // Assuming false
      onAccept: () => _handleAccept(request.id),
      onDecline: () => _handleDecline(request.id),
    );
  }

  Widget _buildErrorState(RequestViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load invitations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.fetchRequests(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(String requestId) async {
    try {
      await ref.read(requestViewModelProvider).acceptRequest(requestId);
      _showSnackBar('Connection invitation accepted');
    } catch (e) {
      _showSnackBar('Failed to accept invitation');
    }
  }

  Future<void> _handleDecline(String requestId) async {
    try {
      await ref.read(requestViewModelProvider).declineRequest(requestId);
      _showSnackBar('Connection invitation declined');
    } catch (e) {
      _showSnackBar('Failed to decline invitation');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
