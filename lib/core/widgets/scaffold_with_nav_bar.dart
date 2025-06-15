import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/newsfeed/presentation/viewmodels/newsfeed_list_viewmodel.dart';
import '../config/router/app_router.dart';
import '../config/router/route_constants.dart';
import '../providers/auth_providers.dart';
import '../providers/realtime_service_provider.dart';
import '../providers/supabase_providers.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RealtimeService의 payloadStream을 listen
    ref.listen<AsyncValue<Map<String, dynamic>>>(newPostStreamProvider, (
      previous,
      next,
    ) {
      if (!context.mounted) return;

      next.whenOrNull(
        data: (newPostPayload) {
          final currentUserId = ref
              .read(supabaseClientProvider)
              .auth
              .currentUser
              ?.id;
          final authorId = newPostPayload['author_id'];

          if (authorId != null && authorId != currentUserId) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('A new post has been uploaded!'),
                action: SnackBarAction(
                  label: 'Refresh',
                  onPressed: () {
                    ref.invalidate(newsfeedListViewModelProvider);
                  },
                ),
              ),
            );
          }
        },
        error: (error, stackTrace) {
          print('Stream error: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to receive Realtime updates'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  if (context.mounted) {
                    ref.invalidate(realtimeServiceProvider);
                  }
                },
              ),
            ),
          );
        },
      );
    });
    final user = ref.watch(authStateStreamProvider).valueOrNull;
    final isAdmin = user?.userMetadata?['role'] == 'admin';

    // 현재 라우트 경로를 가져오기 위해 appRouterProvider를 watch
    final router = ref.watch(appRouterProvider);
    final currentLocation = router.routerDelegate.currentConfiguration.fullPath;

    // 현재 경로가 뉴스피드 최상위 경로인지 확인
    final isNewsfeedHomePage = (currentLocation == RoutePaths.newsfeed);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Newsfeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
      floatingActionButton: (isAdmin && isNewsfeedHomePage)
          ? FloatingActionButton(
              onPressed: () {
                context.push(RoutePaths.newsfeedCreate);
              },
              tooltip: 'Create Newsfeed',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
