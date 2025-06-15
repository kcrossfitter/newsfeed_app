import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/newsfeed_display.dart';
import '../../domain/usecases/update_newsfeed_usecase.dart';
import '../providers/newsfeed_dependency_providers.dart';

part 'edit_newsfeed_viewmodel.g.dart';

@riverpod
class EditNewsfeedViewModel extends _$EditNewsfeedViewModel {
  @override
  FutureOr<void> build() {}

  Future<NewsfeedDisplay?> updateNewsfeed({
    required NewsfeedDisplay originalNewsfeed,
    required String newTitle,
    required String newContent,
    File? newImageFile,
    required bool imageWasRemoved,
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
