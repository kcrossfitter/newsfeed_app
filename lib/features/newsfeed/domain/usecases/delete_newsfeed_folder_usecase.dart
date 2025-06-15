import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/newsfeed_repository.dart';

class DeleteNewsfeedFolderUseCase implements UseCase<void, String> {
  DeleteNewsfeedFolderUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, void>> call(String params) async {
    print('DeleteNewsfeedFolderUseCase: (postId: $params)');
    return await _newsfeedRepository.deleteNewsfeedFolder(postId: params);
  }
}
