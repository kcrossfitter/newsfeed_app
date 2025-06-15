import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/newsfeed_repository.dart';

class CreateNewsfeedParams extends Equatable {
  const CreateNewsfeedParams({
    required this.postId,
    required this.title,
    required this.content,
    this.imageUrl,
  });

  final String postId;
  final String title;
  final String content;
  final String? imageUrl;

  @override
  List<Object?> get props => [postId, title, content, imageUrl];
}

class CreateNewsfeedUseCase implements UseCase<void, CreateNewsfeedParams> {
  CreateNewsfeedUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, void>> call(CreateNewsfeedParams params) async {
    return await _newsfeedRepository.createNewsfeed(
      postId: params.postId,
      title: params.title,
      content: params.content,
      imageUrl: params.imageUrl,
    );
  }
}
