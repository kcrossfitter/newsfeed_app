import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/newsfeed_repository.dart';

class UploadNewsfeedImageParams extends Equatable {
  const UploadNewsfeedImageParams({required this.image, required this.postId});

  final File image;
  final String postId;

  @override
  List<Object> get props => [image, postId];
}

class UploadNewsfeedImageUseCase
    implements UseCase<String, UploadNewsfeedImageParams> {
  UploadNewsfeedImageUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, String>> call(UploadNewsfeedImageParams params) async {
    return await _newsfeedRepository.uploadNewsfeedImage(
      image: params.image,
      postId: params.postId,
    );
  }
}
