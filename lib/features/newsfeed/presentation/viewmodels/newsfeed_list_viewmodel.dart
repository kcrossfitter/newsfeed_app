import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/newsfeed_display.dart';
import '../../domain/usecases/get_newsfeeds_usecase.dart';
import '../providers/newsfeed_dependency_providers.dart';
import '../providers/newsfeed_update_provider.dart';
import '../states/newsfeed_list_state.dart';

part 'newsfeed_list_viewmodel.g.dart';

const _pageSize = 4; // 한 페이지에 불러올 아이템 수

// keepAlive를 true로 설정하여 페이지를 벗어나도 상태가 유지되도록 함
@Riverpod(keepAlive: true)
class NewsfeedListViewModel extends _$NewsfeedListViewModel {
  bool _isFetching = false; // 중복 호출 방지

  // offset 기반으로 데이터를 가져오는 내부 helper method
  Future<List<NewsfeedDisplay>> _fetchNewsfeeds({required int offset}) async {
    final getNewsfeedsUseCase = ref.read(getNewsfeedsUseCaseProvider);
    final result = await getNewsfeedsUseCase(
      GetNewsfeedParams(offset: offset, limit: _pageSize),
    );
    return result.fold((l) => throw l, (r) => r);
  }

  @override
  FutureOr<NewsfeedListState> build() async {
    final newsfeeds = await _fetchNewsfeeds(offset: 0);
    return NewsfeedListState(
      newsfeeds: newsfeeds,
      hasReachedMax: newsfeeds.length < _pageSize,
    );
  }

  Future<void> fetchNextPage() async {
    // 이미 로딩 중이거나, 마지막 페이지에 도달했다면 실행하지 않음
    if (_isFetching || (state.valueOrNull?.hasReachedMax ?? false)) return;

    _isFetching = true;

    final currentState = state.value!;
    final offset = currentState.newsfeeds.length;

    await Future.delayed(const Duration(seconds: 1));

    try {
      final newNewsfeeds = await _fetchNewsfeeds(offset: offset);
      state = AsyncData(
        currentState.copyWith(
          newsfeeds: [...currentState.newsfeeds, ...newNewsfeeds],
          hasReachedMax: newNewsfeeds.length < _pageSize,
        ),
      );
    } catch (e) {
      // 다음 페이지 로딩 실패에 대한 처리 (예: 스낵바 표시)
      // 여기서는 별도 처리 안함
    } finally {
      _isFetching = false;
    }
  }

  // --- 삭제 메소드 추가 ---
  Future<void> deleteNewsfeed(String postId) async {
    final deleteUseCase = ref.read(deleteNewsfeedUseCaseProvider);
    final result = await deleteUseCase(postId);

    result.fold(
      (failure) {
        // DB 삭제 실패 시, 에러 상태로 변경하고 중단
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        // DB 삭제 성공 후의 로직

        // 1. Storage 폴더 삭제를 비동기적으로 호출
        //    이 작업의 성공 여부를 기다리지 않고 다음 UI 업데이트로 넘어감
        //    (소위 "Fire and Forget 방식")
        //    Storage 파일 삭제에 실패하더라도 사용자 경험에 직접적인 영향을 주지 않기 위함
        final deleteFolderUseCase = ref.read(
          deleteNewsfeedFolderUseCaseProvider,
        );
        deleteFolderUseCase(postId);

        // 2. 현재 UI 상태에서 즉시 아이템을 제거하여 사용자에게 빠른 피드백 제공
        final currentState = state.value;
        if (currentState == null) return;

        final updatedNewsfeeds = currentState.newsfeeds
            .where((nf) => nf.postId != postId)
            .toList();

        // 3. "Fetch one to fill" 로직 시작
        // 더 가져올 아이템이 있을 때만 실행
        if (!currentState.hasReachedMax) {
          _isFetching = true; // 중복 호출 방지
          final getNewsfeedsUseCase = ref.read(getNewsfeedsUseCaseProvider);
          getNewsfeedsUseCase(
            GetNewsfeedParams(offset: updatedNewsfeeds.length, limit: 1),
          ).then((fillResult) {
            fillResult.fold(
              (l) {
                // 1개 가져오기 실패 시, 그냥 줄어들 리스트로 업데이트
                state = AsyncData(
                  currentState.copyWith(newsfeeds: updatedNewsfeeds),
                );
              },
              (filledItem) {
                state = AsyncData(
                  currentState.copyWith(
                    newsfeeds: [...updatedNewsfeeds, ...filledItem],
                    // 가져온 게 없으면 마지막
                    hasReachedMax: filledItem.isEmpty,
                  ),
                );
              },
            );
            _isFetching = false;
          });
        } else {
          // 더 가져올 게 없으면 그냥 줄어든 리스트로 상태 업데이트
          state = AsyncData(currentState.copyWith(newsfeeds: updatedNewsfeeds));
        }
      },
    );
  }

  void updateNewsfeedInState(NewsfeedDisplay updatedNewsfeed) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedList = currentState.newsfeeds.map((newsfeed) {
      // postId가 일치하는 아이템을 찾아서 새로운 데이터로 교체
      if (newsfeed.postId == updatedNewsfeed.postId) {
        return updatedNewsfeed;
      }
      return newsfeed;
    }).toList();

    // 교체된 리스트로 상태 업데이트
    state = AsyncData(currentState.copyWith(newsfeeds: updatedList));
  }

  void incrementCommentCount(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedList = currentState.newsfeeds.map((newsfeed) {
      if (newsfeed.postId == postId) {
        return newsfeed.copyWith(commentsCount: newsfeed.commentsCount + 1);
      }
      return newsfeed;
    }).toList();

    state = AsyncData(currentState.copyWith(newsfeeds: updatedList));
  }

  void decrementCommentCount(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedList = currentState.newsfeeds.map((newsfeed) {
      if (newsfeed.postId == postId) {
        return newsfeed.copyWith(commentsCount: newsfeed.commentsCount - 1);
      }
      return newsfeed;
    }).toList();

    state = AsyncData(currentState.copyWith(newsfeeds: updatedList));
  }

  Future<bool> toggleLike(String postId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // 1. rollback을 위해 원본 게시물과 인덱스를 찾음
    final originalNewsfeed = currentState.newsfeeds.firstWhere(
      (n) => n.postId == postId,
    );
    final originalIndex = currentState.newsfeeds.indexOf(originalNewsfeed);

    // 2. UI에 즉시 반영할 '낙관적' 버전의 게시물 생성
    final optimisticNewsfeed = originalNewsfeed.copyWith(
      currentUserLiked: !originalNewsfeed.currentUserLiked,
      likesCount: originalNewsfeed.currentUserLiked
          ? originalNewsfeed.likesCount - 1
          : originalNewsfeed.likesCount + 1,
    );

    // 3. 리스트를 복사하여 '낙관적' 게시물로 교체
    final optimisticList = List<NewsfeedDisplay>.from(currentState.newsfeeds);
    optimisticList[originalIndex] = optimisticNewsfeed;

    // 4. UI를 즉시 업데이트
    state = AsyncData(currentState.copyWith(newsfeeds: optimisticList));

    // 5. 백그라운드에서 실제 서버에 요청
    final toggleLikeUseCase = ref.read(toggleLikeUseCaseProvider);
    final result = await toggleLikeUseCase(postId);

    // 6. 서버 요청 결과 처리
    return result.fold(
      (failure) {
        // 6-A. 실패 시: UI를 원래 상태로 롤백
        final currentListAfterFailure = state.value!.newsfeeds;
        final revertedList = List<NewsfeedDisplay>.from(
          currentListAfterFailure,
        );
        revertedList[originalIndex] = originalNewsfeed; // 원본으로 롤백
        state = AsyncData(state.value!.copyWith(newsfeeds: revertedList));

        // 실패했음을 나타내는 false 반환
        return false;
      },
      (likeResult) {
        // 6-B. 성공 시: 서버가 보내준 최종 데이터로 UI를 다시 보정
        final authoritativeNewsfeed = originalNewsfeed.copyWith(
          currentUserLiked: likeResult.liked,
          likesCount: likeResult.likesCount,
        );
        final currentListAfterSuccess = state.value!.newsfeeds;
        final finalList = List<NewsfeedDisplay>.from(currentListAfterSuccess);
        finalList[originalIndex] = authoritativeNewsfeed;
        state = AsyncData(state.value!.copyWith(newsfeeds: finalList));

        // 업데이트 된 최종 아이템을 이벤트 프로바이더를 통해 앱 전체에 알림
        ref
            .read(newsfeedUpdateEventProvider.notifier)
            .update(authoritativeNewsfeed);

        // 추가: 상세 페이지 provider를 invalidate하여 즉시 갱신
        ref.invalidate(newsfeedDetailProvider(postId));

        // 성공했음을 나타내는 true 반환
        return true;
      },
    );
  }
}
