import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/newsfeed_repository.dart';

class CreateCommentParams extends Equatable {
  const CreateCommentParams({required this.postId, required this.content});

  final String postId;
  final String content;

  @override
  List<Object> get props => [postId, content];
}

class CreateCommentUseCase implements UseCase<void, CreateCommentParams> {
  CreateCommentUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, void>> call(CreateCommentParams params) async {
    return await _newsfeedRepository.createComment(
      postId: params.postId,
      content: params.content,
    );
  }
}
