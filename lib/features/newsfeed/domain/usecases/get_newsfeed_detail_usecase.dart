import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/newsfeed_display.dart';
import '../repositories/newsfeed_repository.dart';

class GetNewsfeedDetailUseCase implements UseCase<NewsfeedDisplay, String> {
  GetNewsfeedDetailUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, NewsfeedDisplay>> call(String params) async {
    return await _newsfeedRepository.getNewsfeedDetail(postId: params);
  }
}
