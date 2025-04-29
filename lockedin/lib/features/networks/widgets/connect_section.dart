import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lockedin/features/networks/viewmodel/suggestion_view_model.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';
import 'package:lockedin/features/networks/widgets/connect_grid.dart';

class ConnectSection extends StatefulWidget {
  const ConnectSection({Key? key}) : super(key: key);

  @override
  State<ConnectSection> createState() => _ConnectSectionState();
}

class _ConnectSectionState extends State<ConnectSection> {
  // Track pending connection requests
  final Set<String> _pendingConnections = {};

  // Track if expanded view is shown
  bool _showExpandedView = false;

  @override
  void initState() {
    super.initState();
    // Fetch suggestions when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SuggestionViewModel>(
        context,
        listen: false,
      );
      viewModel.fetchSuggestions();

      // Initialize pending connections from the ViewModel if available
      if (viewModel.pendingConnectionIds != null) {
        setState(() {
          _pendingConnections.addAll(viewModel.pendingConnectionIds!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Consumer<SuggestionViewModel>(
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
                    "More suggestions for you",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),

              const SizedBox(height: 7),
              Divider(),

              // Show different UI based on the ViewModel state
              _buildSuggestionsContent(viewModel, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsContent(
    SuggestionViewModel viewModel,
    ThemeData theme,
  ) {
    switch (viewModel.state) {
      case SuggestionViewState.loading:
        return SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        );

      case SuggestionViewState.error:
        return SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Could not load suggestions'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => viewModel.fetchSuggestions(),
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Color(0xFF006097)),
                  ),
                ),
              ],
            ),
          ),
        );

      case SuggestionViewState.loaded:
        if (viewModel.suggestionCount == 0) {
          return SizedBox(
            height: 300,
            child: Center(child: Text('No suggestions available')),
          );
        }

        // Get displayed suggestions based on expanded state
        final displayedSuggestions =
            _showExpandedView
                ? viewModel.suggestions
                : viewModel.suggestions
                    .take(viewModel.initialDisplayCount)
                    .toList();

        // Display grid of connection suggestions
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConnectCardsGridView(
              connectCards:
                  displayedSuggestions
                      .map(
                        (suggestion) => ConnectCard(
                          backgroundImage:
                              suggestion.coverPhoto.startsWith('assets/')
                                  ? 'assets/images/default_cover_photo.jpeg'
                                  : suggestion
                                      .coverPhoto, //'assets/images/default_cover_photo.jpeg',
                          profileImage:
                              suggestion.profilePicture != ''
                                  ? NetworkImage(suggestion.profilePicture)
                                  : AssetImage(
                                        'assets/images/default_cover_photo.jpeg',
                                      )
                                      as ImageProvider,
                          name:
                              "${suggestion.firstName} ${suggestion.lastName}",
                          headline: suggestion.headline,
                          onCardTap: () => _handleCardTap(suggestion.id),
                          isPending: _pendingConnections.contains(
                            suggestion.id,
                          ),
                          onConnectTap:
                              () => _handleConnect(suggestion.id, viewModel),
                        ),
                      )
                      .toList(),
            ),
            if (viewModel.hasMoreSuggestions && !_showExpandedView)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showExpandedView = true;

                      // Load more suggestions if needed
                      if (viewModel.shouldLoadMoreOnExpand) {
                        viewModel.loadAllSuggestions();
                      }
                    });
                  },
                  child: Text(
                    'See all suggestions',
                    style: TextStyle(color: Color(0xFF006097)),
                  ),
                ),
              ),
            if (_showExpandedView)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showExpandedView = false;
                    });
                  },
                  child: Text(
                    'Show less',
                    style: TextStyle(color: Color(0xFF006097)),
                  ),
                ),
              ),
          ],
        );

      case SuggestionViewState.initial:
      default:
        return SizedBox(height: 300);
    }
  }

  // Handle connect action
  Future<void> _handleConnect(
    String suggestionId,
    SuggestionViewModel viewModel,
  ) async {
    // Don't do anything if already pending
    if (_pendingConnections.contains(suggestionId)) {
      return;
    }

    try {
      // Set as pending immediately for UI feedback
      setState(() {
        _pendingConnections.add(suggestionId);
      });

      // Send the connection request
      await viewModel.sendConnectionRequest(suggestionId);

      // Maintain the pending state (don't remove from _pendingConnections)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request sent'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // If request fails, revert the pending state
      if (mounted) {
        setState(() {
          _pendingConnections.remove(suggestionId);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send connection request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCardTap(String userId) {
    context.pushNamed('other-profile', pathParameters: {'userId': userId});
  }
}
