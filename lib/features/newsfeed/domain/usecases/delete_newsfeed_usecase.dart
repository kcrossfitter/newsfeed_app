import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/newsfeed_repository.dart';

class DeleteNewsfeedUseCase implements UseCase<void, String> {
  DeleteNewsfeedUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await _newsfeedRepository.deleteNewsfeed(postId: params);
  }
}
