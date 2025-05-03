// lib/features/search/view/search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/network_repository.dart';
import '../../../shared/widgets/upper_navbar.dart';
import '../widgets/search_result.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UpperNavbar(
        leftIcon: Icon(Icons.menu),
        leftOnPress: () {
          // Open drawer or go back
          Scaffold.of(context).openDrawer();
        },
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final searchQuery = ref.watch(searchQueryProvider);
              if (searchQuery.isNotEmpty && searchQuery.length >= 2) {
                return Expanded(child: SearchResultsWidget());
              } else {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for users',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}