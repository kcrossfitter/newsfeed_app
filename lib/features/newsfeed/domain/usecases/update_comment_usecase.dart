import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment_display.dart';
import '../repositories/newsfeed_repository.dart';

class UpdateCommentParams extends Equatable {
  const UpdateCommentParams({
    required this.commentId,
    required this.newContent,
  });

  final String commentId;
  final String newContent;

  @override
  List<Object> get props => [commentId, newContent];
}

class UpdateCommentUseCase
    implements UseCase<CommentDisplay, UpdateCommentParams> {
  UpdateCommentUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, CommentDisplay>> call(
    UpdateCommentParams params,
  ) async {
    return await _newsfeedRepository.updateComment(
      commentId: params.commentId,
      newContent: params.newContent,
    );
  }
}
