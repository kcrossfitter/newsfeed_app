import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment_display.dart';
import '../repositories/newsfeed_repository.dart';

class GetCommentsParams extends Equatable {
  const GetCommentsParams({
    required this.postId,
    required this.offset,
    this.limit = 10,
  });

  final String postId;
  final int offset;
  final int limit;

  @override
  List<Object> get props => [postId, offset, limit];
}

class GetCommentsUseCase
    implements UseCase<List<CommentDisplay>, GetCommentsParams> {
  GetCommentsUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, List<CommentDisplay>>> call(
    GetCommentsParams params,
  ) async {
    return await _newsfeedRepository.getComments(
      postId: params.postId,
      offset: params.offset,
      limit: params.limit,
    );
  }
}
