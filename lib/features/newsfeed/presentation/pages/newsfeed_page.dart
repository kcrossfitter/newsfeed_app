import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../states/newsfeed_list_state.dart';
import '../viewmodels/newsfeed_list_viewmodel.dart';
import '../widgets/newsfeed_card.dart';

class NewsfeedPage extends ConsumerStatefulWidget {
  const NewsfeedPage({super.key});

  @override
  ConsumerState<NewsfeedPage> createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends ConsumerState<NewsfeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 100px 전에 미리 로드
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsfeedListViewModelProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabaseUser = ref.watch(authStateStreamProvider).valueOrNull;
    final String username =
        supabaseUser?.userMetadata?['username'] as String? ?? 'Guest';
    final String role =
        supabaseUser?.userMetadata?['role'] as String? ?? 'user';

    // newsfeed 목록 상태 watch
    final newsfeedListState = ref.watch(newsfeedListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NewsFeed'),
        actions: [
          // 사용자 정보 표시
          if (supabaseUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Tooltip(
                  message: role == 'admin'
                      ? 'Admin: $username'
                      : username, // 툴팁 내용도 업데이트
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width * 0.25, // 필요시 조정
                    ),
                    child: Text(
                      // 관리자인 경우 '(A) $username', 일반 사용자는 이름만
                      role == 'admin' ? '(A) $username' : username,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: newsfeedListState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(child: Text('Error: $error'));
        },
        data: (NewsfeedListState state) {
          if (state.newsfeeds.isEmpty) {
            return const Center(child: Text('No newsfeeds yet'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(newsfeedListViewModelProvider);
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.hasReachedMax
                  ? state
                        .newsfeeds
                        .length // 마지막 페이지면 아이템 개수만
                  : state.newsfeeds.length + 1, // 아니면 login indicator 용 추가
              itemBuilder: (context, index) {
                if (index >= state.newsfeeds.length) {
                  // 마지막 아이템이면 로딩 인디케이터 표시
                  return const Center(child: CircularProgressIndicator());
                }
                final newsfeed = state.newsfeeds[index];
                return NewsfeedCard(newsfeed: newsfeed);
              },
            ),
          );
        },
      ),
    );
  }
}
