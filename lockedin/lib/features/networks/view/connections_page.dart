import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/networks/widgets/connection.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:lockedin/features/networks/viewmodel/connection_view_model.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  final ScrollController _scrollController = ScrollController();
  late final ConnectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ConnectionViewModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchConnections();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_viewModel.state != ConnectionViewState.loading) {
        _viewModel.loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Connections', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        iconTheme: theme.iconTheme,
      ),
      body: ChangeNotifierProvider.value(
        value: _viewModel, // Use the existing ViewModel instance
        child: SafeArea(
          minimum: EdgeInsets.all(10.px),
          child: Consumer<ConnectionViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  const Divider(),
                  _buildConnectionHeader(viewModel),
                  const Divider(),
                  Expanded(child: _buildConnectionsList(viewModel)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionHeader(ConnectionViewModel viewModel) {
    return Row(
      children: [
        Text(
          '${viewModel.connectionCount} Connections',
          style: const TextStyle(fontSize: 18),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            // Implement search functionality
            // showSearch(
            //   context: context,
            //   delegate: ConnectionSearchDelegate(viewModel.connections),
            // );
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
            _showFilterBottomSheet();
          },
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }

  Widget _buildConnectionsList(ConnectionViewModel viewModel) {
    switch (viewModel.state) {
      case ConnectionViewState.initial:
        return const Center(child: Text('Loading connections...'));

      case ConnectionViewState.loading:
        if (viewModel.connections.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return _buildConnectionsListWithData(viewModel, isLoading: true);
        }

      case ConnectionViewState.loaded:
        if (viewModel.connections.isEmpty) {
          return const Center(child: Text('No connections found'));
        } else {
          return _buildConnectionsListWithData(viewModel);
        }

      case ConnectionViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${viewModel.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.fetchConnections(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildConnectionsListWithData(
    ConnectionViewModel viewModel, {
    bool isLoading = false,
  }) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: viewModel.connections.length + (isLoading ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (isLoading && index == viewModel.connections.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final connection = viewModel.connections[index];
        return Connection(
          profileImage:
              connection.profilePicture.isNotEmpty
                  ? NetworkImage(connection.profilePicture)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
          firstName: connection.firstName,
          lastName: connection.lastName,
          lastJobTitle: connection.lastJobTitle,
          onNameTap: () {
            context.push('/other-profile/${connection.id}');
          },
          onRemove: () => viewModel.removeConnection(connection.id),
        );
      },
    );
  }

  Future<bool?> _showRemoveConfirmationDialog(Connection connection) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Connection'),
            content: Text(
              'Are you sure you want to remove ${connection.firstName} ${connection.lastName} from your connections?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Connections',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // TODO: Implement filter options
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Sort by name'),
                  onTap: () {
                    // Implement sort by name
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Filter by job title'),
                  onTap: () {
                    // Implement filter by job title
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
    );
  }
}

class ConnectionSearchDelegate extends SearchDelegate<String> {
  final List<Connection> connections;

  ConnectionSearchDelegate(this.connections);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredConnections =
        connections.where((connection) {
          final fullName =
              '${connection.firstName} ${connection.lastName}'.toLowerCase();
          final jobTitle = connection.lastJobTitle.toLowerCase();
          final queryLower = query.toLowerCase();

          return fullName.contains(queryLower) || jobTitle.contains(queryLower);
        }).toList();

    return ListView.separated(
      itemCount: filteredConnections.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final connection = filteredConnections[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                connection.profilePicture.isNotEmpty
                    ? NetworkImage(connection.profilePicture)
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
          ),
          title: Text('${connection.firstName} ${connection.lastName}'),
          subtitle: Text(connection.lastJobTitle),
        );
      },
    );
  }
}
