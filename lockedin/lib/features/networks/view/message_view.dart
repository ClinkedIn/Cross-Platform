import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/message_request_model.dart';
import '../viewmodel/message_view_model.dart';
import '../widgets/message_item.dart';

class MessageRequestListScreen extends StatefulWidget {
  const MessageRequestListScreen({Key? key}) : super(key: key);

  @override
  State<MessageRequestListScreen> createState() =>
      _MessageRequestListScreenState();
}

class _MessageRequestListScreenState extends State<MessageRequestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load message requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageRequestViewModel>().loadMessageRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Processed')],
        ),
      ),
      body: Consumer<MessageRequestViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadMessageRequests(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadMessageRequests(),
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending requests tab
                _buildRequestsList(viewModel.pendingRequests),

                // Processed requests tab
                _buildRequestsList(
                  viewModel.processedRequests,
                  showActions: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(
    List<MessageRequest> requests, {
    bool showActions = true,
  }) {
    if (requests.isEmpty) {
      return const Center(child: Text('No requests found'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return MessageRequestItem(
          request: requests[index],
          showActions: showActions,
        );
      },
    );
  }
}
