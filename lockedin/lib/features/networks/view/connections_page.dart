import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/connection_model.dart';
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
  // Initialize filter
  final ConnectionFilter _filter = ConnectionFilter();
  // List of common job titles for filtering
  final List<String> _commonJobTitles = [
    'Software Engineer',
    'Product Manager',
    'Data Scientist',
    'Designer',
    'Marketing',
    'Sales',
    'HR',
    'Founder',
    'Student',
    'Other',
  ];

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

  // Apply current filters to connections
  List<ConnectionModel> _getFilteredConnections(
    List<ConnectionModel> connections,
  ) {
    // Create a copy to avoid modifying the original list
    List<ConnectionModel> filteredList = List.from(connections);

    // Apply job title filter if set
    if (_filter.jobTitleFilter != null && _filter.jobTitleFilter!.isNotEmpty) {
      filteredList =
          filteredList.where((connection) {
            return connection.lastJobTitle.toLowerCase().contains(
              _filter.jobTitleFilter!.toLowerCase(),
            );
          }).toList();
    }

    // Apply sorting
    switch (_filter.sortOption) {
      case SortOption.nameAsc:
        filteredList.sort(
          (a, b) => '${a.firstName} ${a.lastName}'.compareTo(
            '${b.firstName} ${b.lastName}',
          ),
        );
        break;
      case SortOption.nameDesc:
        filteredList.sort(
          (a, b) => '${b.firstName} ${b.lastName}'.compareTo(
            '${a.firstName} ${a.lastName}',
          ),
        );
        break;
      case SortOption.jobTitleAsc:
        filteredList.sort((a, b) => a.lastJobTitle.compareTo(b.lastJobTitle));
        break;
      case SortOption.jobTitleDesc:
        filteredList.sort((a, b) => b.lastJobTitle.compareTo(a.lastJobTitle));
        break;
    }

    return filteredList;
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
        value: _viewModel,
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
            showSearch(
              context: context,
              delegate: ConnectionSearchDelegate(viewModel.connections),
            );
          },
          icon: const Icon(Icons.search),
          tooltip: 'Search connections',
        ),
        IconButton(
          onPressed: () {
            _showFilterBottomSheet();
          },
          icon: const Icon(Icons.tune),
          tooltip: 'Filter connections',
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
          // Apply filtering to the connections
          final filteredConnections = _getFilteredConnections(
            viewModel.connections,
          );
          return _buildConnectionsListWithData(
            viewModel,
            filteredConnections,
            isLoading: true,
          );
        }

      case ConnectionViewState.loaded:
        if (viewModel.connections.isEmpty) {
          return const Center(child: Text('No connections found'));
        } else {
          // Apply filtering to the connections
          final filteredConnections = _getFilteredConnections(
            viewModel.connections,
          );
          if (filteredConnections.isEmpty) {
            return const Center(
              child: Text('No connections match your filters'),
            );
          }
          return _buildConnectionsListWithData(viewModel, filteredConnections);
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
    ConnectionViewModel viewModel,
    List<ConnectionModel> connections, {
    bool isLoading = false,
  }) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: connections.length + (isLoading ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (isLoading && index == connections.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final connectionModel = connections[index];
        return Connection(
          profileImage:
              connectionModel.profilePicture.isNotEmpty
                  ? NetworkImage(connectionModel.profilePicture)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
          firstName: connectionModel.firstName,
          lastName: connectionModel.lastName,
          lastJobTitle: connectionModel.lastJobTitle,
          onNameTap: () {
            context.push('/other-profile/${connectionModel.id}');
          },
          onRemove:
              () => _showRemoveConfirmationDialog(connectionModel).then((
                confirmed,
              ) {
                if (confirmed == true) {
                  viewModel.removeConnection(connectionModel.id);
                }
              }),
        );
      },
    );
  }

  Future<bool?> _showRemoveConfirmationDialog(ConnectionModel connection) {
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
    // Make temporary filter to avoid applying changes until user clicks "Apply"
    ConnectionFilter tempFilter = ConnectionFilter(
      sortOption: _filter.sortOption,
      jobTitleFilter: _filter.jobTitleFilter,
    );

    // Text editing controller with proper initial value
    final TextEditingController _textController = TextEditingController(
      text: _filter.jobTitleFilter ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: const EdgeInsets.all(16),
                  // Use more height for the modal
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button - Keep this outside the scrollable area
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Connections',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Make the content scrollable
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              // Sort options
                              const Text(
                                'Sort by',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),

                              RadioListTile<SortOption>(
                                title: const Text('Name (A-Z)'),
                                value: SortOption.nameAsc,
                                groupValue: tempFilter.sortOption,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempFilter.sortOption = value!;
                                  });
                                },
                              ),
                              RadioListTile<SortOption>(
                                title: const Text('Name (Z-A)'),
                                value: SortOption.nameDesc,
                                groupValue: tempFilter.sortOption,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempFilter.sortOption = value!;
                                  });
                                },
                              ),
                              RadioListTile<SortOption>(
                                title: const Text('Job Title (A-Z)'),
                                value: SortOption.jobTitleAsc,
                                groupValue: tempFilter.sortOption,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempFilter.sortOption = value!;
                                  });
                                },
                              ),
                              RadioListTile<SortOption>(
                                title: const Text('Job Title (Z-A)'),
                                value: SortOption.jobTitleDesc,
                                groupValue: tempFilter.sortOption,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempFilter.sortOption = value!;
                                  });
                                },
                              ),

                              const Divider(),
                              const SizedBox(height: 8),

                              // Job title filter
                              const Text(
                                'Filter by job title',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // *** FIX FOR TEXT FIELD DIRECTION ISSUE ***
                              // Apply Directionality at the highest level needed
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Material(
                                  // Add Material widget to ensure proper inheritance of theme properties
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _textController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Enter job title to filter',
                                            prefixIcon: const Icon(Icons.work),
                                            suffixIcon:
                                                tempFilter.jobTitleFilter !=
                                                            null &&
                                                        tempFilter
                                                            .jobTitleFilter!
                                                            .isNotEmpty
                                                    ? IconButton(
                                                      icon: const Icon(
                                                        Icons.clear,
                                                      ),
                                                      onPressed: () {
                                                        setModalState(() {
                                                          tempFilter
                                                                  .jobTitleFilter =
                                                              null;
                                                          _textController
                                                              .clear();
                                                        });
                                                      },
                                                    )
                                                    : null,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.left,
                                          onChanged: (value) {
                                            setModalState(() {
                                              tempFilter.jobTitleFilter =
                                                  value.isEmpty ? null : value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Common job titles
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    _commonJobTitles.map((title) {
                                      bool isSelected =
                                          tempFilter.jobTitleFilter == title;
                                      return FilterChip(
                                        label: Text(title),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setModalState(() {
                                            if (selected) {
                                              tempFilter.jobTitleFilter = title;
                                              _textController.text = title;
                                            } else if (isSelected) {
                                              tempFilter.jobTitleFilter = null;
                                              _textController.clear();
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),

                              // Add some padding at the bottom for better spacing
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // Action buttons - Keep this outside the scrollable area
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Reset filters
                                  setState(() {
                                    _filter.sortOption = SortOption.nameAsc;
                                    _filter.jobTitleFilter = null;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Reset'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Apply filters
                                  setState(() {
                                    _filter.sortOption = tempFilter.sortOption;
                                    _filter.jobTitleFilter =
                                        tempFilter.jobTitleFilter;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Apply'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class ConnectionSearchDelegate extends SearchDelegate<String> {
  final List<ConnectionModel> connections;

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
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for connections by name or job title',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final filteredConnections =
        connections.where((connection) {
          final fullName =
              '${connection.firstName} ${connection.lastName}'.toLowerCase();
          final jobTitle = connection.lastJobTitle.toLowerCase();
          final queryLower = query.toLowerCase();

          return fullName.contains(queryLower) || jobTitle.contains(queryLower);
        }).toList();

    if (filteredConnections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No connections found for "$query"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

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
          onTap: () {
            // Navigate to profile when tapped
            GoRouter.of(context).push('/other-profile/${connection.id}');
            close(context, connection.id);
          },
        );
      },
    );
  }
}
