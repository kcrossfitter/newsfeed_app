import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/like_result.dart';
import '../repositories/newsfeed_repository.dart';

class ToggleLikeUseCase implements UseCase<LikeResult, String> {
  ToggleLikeUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, LikeResult>> call(String params) async {
    return await _newsfeedRepository.toggleLike(postId: params);
  }
}
