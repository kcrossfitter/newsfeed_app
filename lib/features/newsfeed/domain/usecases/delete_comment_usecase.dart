import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/newsfeed_repository.dart';

class DeleteCommentUseCase implements UseCase<void, String> {
  DeleteCommentUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await _newsfeedRepository.deleteComment(commentId: params);
  }
}
