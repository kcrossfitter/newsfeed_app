import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/search_viewmodel.dart';
import '../widgets/newsfeed_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchViewModelProvider.notifier).search(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchViewModelProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search newsfeeds...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSearchSubmitted,
        ),
        actions: [
          IconButton(onPressed: _clearSearch, icon: const Icon(Icons.clear)),
        ],
      ),
      body: searchState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (newsfeeds) {
          // 아직 검색어를 입력하지 않은 초기 상태
          if (_searchController.text.trim().isEmpty) {
            return const Center(
              child: Text('Enter a query to search for newsfeeds.'),
            );
          }
          // 검색 결과가 없을 때
          if (newsfeeds.isEmpty) {
            return const Center(child: Text('No results found'));
          }
          // 검색 결과가 있을 때
          return ListView.builder(
            itemCount: newsfeeds.length,
            itemBuilder: (context, index) {
              return NewsfeedCard(
                newsfeed: newsfeeds[index],
                detailRouteName: 'searchNewsfeedDetail',
              );
            },
          );
        },
      ),
    );
  }
}
