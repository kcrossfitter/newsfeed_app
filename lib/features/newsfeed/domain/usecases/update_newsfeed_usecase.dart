import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/newsfeed_display.dart';
import '../repositories/newsfeed_repository.dart';

class UpdateNewsfeedParams extends Equatable {
  const UpdateNewsfeedParams({
    required this.originalNewsfeed,
    required this.newTitle,
    required this.newContent,
    this.newImageFile,
    this.imageWasRemoved = false,
  });

  final NewsfeedDisplay originalNewsfeed;
  final String newTitle;
  final String newContent;
  final File? newImageFile;
  final bool imageWasRemoved;

  @override
  List<Object?> get props {
    return [
      originalNewsfeed,
      newTitle,
      newContent,
      newImageFile,
      imageWasRemoved,
    ];
  }
}

class UpdateNewsfeedUseCase
    implements UseCase<NewsfeedDisplay, UpdateNewsfeedParams> {
  UpdateNewsfeedUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, NewsfeedDisplay>> call(
    UpdateNewsfeedParams params,
  ) async {
    try {
      String? finalImageUrl = params.originalNewsfeed.imageUrl;

      // 시나리오 1: 새 이미지로 교체
      if (params.newImageFile != null) {
        // 기존 이미지가 있으면 폴더 삭제
        if (params.originalNewsfeed.imageUrl != null) {
          await _newsfeedRepository.deleteNewsfeedFolder(
            postId: params.originalNewsfeed.postId,
          );
        }

        // 새 이미지 업로드
        final uploadResult = await _newsfeedRepository.uploadNewsfeedImage(
          image: params.newImageFile!,
          postId: params.originalNewsfeed.postId,
        );

        // 업로드 결과에 따라 finalImageUrl 업데이트
        finalImageUrl = uploadResult.fold(
          (failure) => null, // 실패 시 에러를 던져 catch block으로 보냄
          (url) => url,
        );

        // finalImageUrl이 null이면 업로드 실패이므로 에러 반환
        if (finalImageUrl == null) {
          return const Left(
            ServerFailure(message: 'Failed to upload new image.'),
          );
        }
      }
      // 시나리오 2: 기존 이미지 제거
      else if (params.imageWasRemoved &&
          params.originalNewsfeed.imageUrl != null) {
        await _newsfeedRepository.deleteNewsfeedFolder(
          postId: params.originalNewsfeed.postId,
        );
        finalImageUrl = null;
      }

      // 최종적으로 DB 업데이트
      return await _newsfeedRepository.updateNewsfeed(
        postId: params.originalNewsfeed.postId,
        title: params.newTitle,
        content: params.newContent,
        imageUrl: finalImageUrl,
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// import 'package:equatable/equatable.dart';
// import 'package:fpdart/fpdart.dart';

// import '../../../../core/errors/failures.dart';
// import '../../../../core/usecase/usecase.dart';
// import '../entities/newsfeed_display.dart';
// import '../repositories/newsfeed_repository.dart';

// class UpdateNewsfeedParams extends Equatable {
//   const UpdateNewsfeedParams({
//     required this.postId,
//     required this.title,
//     required this.content,
//     this.imageUrl,
//   });

//   final String postId;
//   final String title;
//   final String content;
//   final String? imageUrl;

//   @override
//   List<Object?> get props => [postId, title, content, imageUrl];
// }

// class UpdateNewsfeedUseCase
//     implements UseCase<NewsfeedDisplay, UpdateNewsfeedParams> {
//   UpdateNewsfeedUseCase({required NewsfeedRepository newsfeedRepository})
//     : _newsfeedRepository = newsfeedRepository;

//   final NewsfeedRepository _newsfeedRepository;

//   @override
//   Future<Either<Failure, NewsfeedDisplay>> call(
//     UpdateNewsfeedParams params,
//   ) async {
//     return await _newsfeedRepository.updateNewsfeed(
//       postId: params.postId,
//       title: params.title,
//       content: params.content,
//       imageUrl: params.imageUrl,
//     );
//   }
// }
