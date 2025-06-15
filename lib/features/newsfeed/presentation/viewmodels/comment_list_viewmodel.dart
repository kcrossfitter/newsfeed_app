import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/create_comment_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';
import '../providers/newsfeed_dependency_providers.dart';
import '../states/comment_list_state.dart';
import 'newsfeed_list_viewmodel.dart';

part 'comment_list_viewmodel.g.dart';

const _commentPageSize = 10;

@riverpod
class CommentListViewModel extends _$CommentListViewModel {
  bool _isFetching = false;

  // build 메소드가 postId를 파라미터로 받습니다.
  @override
  Future<CommentListState> build(String postId) async {
    final getCommentsUseCase = ref.read(getCommentsUseCaseProvider);
    final result = await getCommentsUseCase(
      GetCommentsParams(postId: postId, offset: 0, limit: _commentPageSize),
    );

    return result.fold((failure) => throw failure, (comments) {
      print('comments.length: ${comments.length}');
      return CommentListState(
        comments: comments,
        hasReachedMax: comments.length < _commentPageSize,
      );
    });
  }

  Future<void> fetchNextPage(String postId) async {
    if (_isFetching || (state.valueOrNull?.hasReachedMax ?? true)) return;
    _isFetching = true;

    final offset = state.value!.comments.length;
    final getCommentsUseCase = ref.read(getCommentsUseCaseProvider);
    await Future.delayed(const Duration(seconds: 1));
    final result = await getCommentsUseCase(
      GetCommentsParams(
        postId: postId,
        offset: offset,
        limit: _commentPageSize,
      ),
    );

    result.fold(
      (failure) {
        /* 에러 처리, 필요시 구현 */
      },
      (newComments) {
        print('newComments.length: ${newComments.length}');
        final currentState = state.value!;
        state = AsyncData(
          currentState.copyWith(
            comments: [...currentState.comments, ...newComments],
            hasReachedMax: newComments.length < _commentPageSize,
          ),
        );
      },
    );
    _isFetching = false;
  }

  Future<bool> addComment(String content) async {
    final createCommentUseCase = ref.read(createCommentUseCaseProvider);
    final result = await createCommentUseCase(
      CreateCommentParams(postId: postId, content: content),
    );

    return result.fold(
      (failure) {
        return false;
      },
      (_) {
        // 1. Newsfeed 목록의 댓글 카운트 업데이트 요청
        ref
            .read(newsfeedListViewModelProvider.notifier)
            .incrementCommentCount(postId);
        // 2. true 리턴
        return true;
      },
    );
  }

  Future<bool> deleteComment(String commentId) async {
    final deleteCommentUseCase = ref.read(deleteCommentUseCaseProvider);
    final result = await deleteCommentUseCase(commentId);

    return result.fold(
      (failure) {
        // 실패 시 false 반환
        return false;
      },
      (_) {
        // 1. 뉴스피드 목록의 댓글 카운트 감소 요청
        ref
            .read(newsfeedListViewModelProvider.notifier)
            .decrementCommentCount(postId);
        // 2. 현재 댓글 목록 상태에서 해당 댓글 제거
        final currentState = state.value;
        // state가 null일 경우 성공 처리
        if (currentState == null) return true;

        final updatedComments = currentState.comments
            .where((comment) => comment.id != commentId)
            .toList();

        // 3. 삭제된 빈 자리 채우기 로직
        if (!currentState.hasReachedMax) {
          _isFetching = true; // 중복 호출 방지
          final getCommentsUseCase = ref.read(getCommentsUseCaseProvider);
          getCommentsUseCase(
            GetCommentsParams(
              postId: postId,
              offset: updatedComments.length,
              limit: 1,
            ),
          ).then((fillResult) {
            fillResult.fold(
              (l) {
                // 1개 가져오기 실패 시, 그냥 줄어든 리스트로 상태 업데이트
                state = AsyncData(
                  currentState.copyWith(comments: updatedComments),
                );
              },
              (filledItems) {
                // 1개 가져오기 성공 시, 합쳐서 상태 업데이트
                print('fetching 1 more item: ${filledItems.first}');
                state = AsyncData(
                  currentState.copyWith(
                    comments: [...updatedComments, ...filledItems],
                    hasReachedMax: filledItems.isEmpty,
                  ),
                );
              },
            );
            _isFetching = false;
          });
        } else {
          // 더 가져올 아이템이 없으면, 그냥 줄어든 리스트로 상태 업데이트
          state = AsyncData(currentState.copyWith(comments: updatedComments));
        }

        return true;
      },
    );
  }

  Future<bool> updateComment({
    required String commentId,
    required String newContent,
  }) async {
    final updateCommentUseCase = ref.read(updateCommentUseCaseProvider);
    final result = await updateCommentUseCase(
      UpdateCommentParams(commentId: commentId, newContent: newContent),
    );

    return result.fold((failure) => false, (updatedComment) {
      final currentState = state.value;
      if (currentState == null) return true;

      // 목록에서 수정된 댓글을 찾아 교체
      final updatedList = currentState.comments.map((comment) {
        if (comment.id == updatedComment.id) {
          return updatedComment;
        }
        return comment;
      }).toList();

      // 교체된 list로 상태 업데이트
      state = AsyncData(currentState.copyWith(comments: updatedList));
      return true;
    });
  }
}
