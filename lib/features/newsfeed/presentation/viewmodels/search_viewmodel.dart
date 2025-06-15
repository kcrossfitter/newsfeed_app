import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/newsfeed_display.dart';
import '../providers/newsfeed_dependency_providers.dart';
import '../providers/newsfeed_update_provider.dart';

part 'search_viewmodel.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  @override
  FutureOr<List<NewsfeedDisplay>> build() async {
    // newsfeedUpdateEventProvider의 상태 변화를 listen
    ref.listen(newsfeedUpdateEventProvider, (previous, next) {
      if (next != null) {
        // 자신의 상태에 해당 아이템이 있는지 확인하고 교체
        updateItemInState(next);
      }
    });
    return [];
  }

  Future<void> search(String query) async {
    // 1. 로딩 상태 설정
    state = const AsyncLoading();
    // 2. Usecase 실행
    final searchUseCase = ref.read(searchNewsfeedsUseCaseProvider);
    final result = await searchUseCase(query);
    // 3. 결과에 따른 상태 업데이트
    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (newsfeeds) {
        state = AsyncData(newsfeeds);
      },
    );
  }

  void clear() {
    state = const AsyncData([]);
  }

  void updateItemInState(NewsfeedDisplay updatedNewsfeed) {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isEmpty) return;

    final updatedList = currentState.map((newsfeed) {
      if (newsfeed.postId == updatedNewsfeed.postId) {
        return updatedNewsfeed;
      }
      return newsfeed;
    }).toList();

    state = AsyncData(updatedList);
  }
}
