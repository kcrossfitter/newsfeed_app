import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/newsfeed_display.dart';
import '../../domain/usecases/create_newsfeed_usecase.dart';
import '../../domain/usecases/update_newsfeed_usecase.dart';
import '../../domain/usecases/upload_newsfeed_image_usecase.dart';
import '../providers/newsfeed_dependency_providers.dart';

part 'create_newsfeed_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class CreateNewsfeedViewModel extends _$CreateNewsfeedViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> createNewsfeed({
    required String title,
    required String content,
    File? imageFile,
  }) async {
    state = const AsyncLoading();

    // 1. Client에서 postId 미리 생성
    final postId = const Uuid().v4();
    String? imageUrl;

    // 1. 이미지 파일이 있으면 먼저 업로드
    if (imageFile != null) {
      final uploadUseCase = ref.read(uploadNewsfeedImageUseCaseProvider);
      final result = await uploadUseCase(
        UploadNewsfeedImageParams(image: imageFile, postId: postId),
      );

      // 이미지 업로드 처리 결과
      final success = result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
          return false;
        },
        (url) {
          imageUrl = url; // 성공 시 URL 저장
          return true;
        },
      );

      // 이미지 업로드 실패 시, 뉴스피드 생성 중단
      if (!success) return;
    }

    final createNewsfeedUseCase = ref.read(createNewsfeedUseCaseProvider);
    final params = CreateNewsfeedParams(
      postId: postId,
      title: title,
      content: content,
      imageUrl: imageUrl, // 업로드 된 이미지 URL 또는 null
    );
    final result = await createNewsfeedUseCase(params);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        state = const AsyncData(null);
      },
    );
  }

  Future<NewsfeedDisplay?> updateNewsfeed({
    required NewsfeedDisplay originalNewsfeed,
    required String newTitle,
    required String newContent,
    File? newImageFile,
    required bool imageWasRemoved, // UI에서 이미지 제거 버튼을 눌렀는지 여부
  }) async {
    state = const AsyncLoading();

    final updateUseCase = ref.read(updateNewsfeedUseCaseProvider);
    final params = UpdateNewsfeedParams(
      originalNewsfeed: originalNewsfeed,
      newTitle: newTitle,
      newContent: newContent,
      newImageFile: newImageFile,
      imageWasRemoved: imageWasRemoved,
    );

    final result = await updateUseCase(params);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (updatedNewsfeed) {
        state = const AsyncData(null);
        return updatedNewsfeed;
      },
    );
  }
}
