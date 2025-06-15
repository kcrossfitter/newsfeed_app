import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_providers.dart';
import '../../data/datasources/newsfeed_remote_data_source.dart';
import '../../data/datasources/supabase_newsfeed_remote_data_source.dart';
import '../../data/repositories/newsfeed_repository_impl.dart';
import '../../domain/entities/newsfeed_display.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../../domain/usecases/create_comment_usecase.dart';
import '../../domain/usecases/create_newsfeed_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/delete_newsfeed_folder_usecase.dart';
import '../../domain/usecases/delete_newsfeed_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/get_newsfeed_detail_usecase.dart';
import '../../domain/usecases/get_newsfeeds_usecase.dart';
import '../../domain/usecases/search_newsfeeds_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';
import '../../domain/usecases/update_newsfeed_usecase.dart';
import '../../domain/usecases/upload_newsfeed_image_usecase.dart';

part 'newsfeed_dependency_providers.g.dart';

@riverpod
NewsfeedRemoteDataSource newsfeedRemoteDataSource(Ref ref) {
  return SupabaseNewsfeedRemoteDataSource(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}

@riverpod
NewsfeedRepository newsfeedRepository(Ref ref) {
  return NewsfeedRepositoryImpl(
    newsfeedRemoteDataSource: ref.watch(newsfeedRemoteDataSourceProvider),
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}

@riverpod
CreateNewsfeedUseCase createNewsfeedUseCase(Ref ref) {
  return CreateNewsfeedUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
GetNewsfeedsUseCase getNewsfeedsUseCase(Ref ref) {
  return GetNewsfeedsUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
UploadNewsfeedImageUseCase uploadNewsfeedImageUseCase(Ref ref) {
  return UploadNewsfeedImageUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
DeleteNewsfeedUseCase deleteNewsfeedUseCase(Ref ref) {
  return DeleteNewsfeedUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
UpdateNewsfeedUseCase updateNewsfeedUseCase(Ref ref) {
  return UpdateNewsfeedUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
DeleteNewsfeedFolderUseCase deleteNewsfeedFolderUseCase(Ref ref) {
  return DeleteNewsfeedFolderUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
GetCommentsUseCase getCommentsUseCase(Ref ref) {
  return GetCommentsUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
CreateCommentUseCase createCommentUseCase(Ref ref) {
  return CreateCommentUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
DeleteCommentUseCase deleteCommentUseCase(Ref ref) {
  return DeleteCommentUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
UpdateCommentUseCase updateCommentUseCase(Ref ref) {
  return UpdateCommentUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
ToggleLikeUseCase toggleLikeUseCase(Ref ref) {
  return ToggleLikeUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
SearchNewsfeedsUseCase searchNewsfeedsUseCase(Ref ref) {
  return SearchNewsfeedsUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
GetNewsfeedDetailUseCase getNewsfeedDetailUseCase(Ref ref) {
  return GetNewsfeedDetailUseCase(
    newsfeedRepository: ref.watch(newsfeedRepositoryProvider),
  );
}

@riverpod
FutureOr<NewsfeedDisplay> newsfeedDetail(Ref ref, String postId) {
  final usecase = ref.watch(getNewsfeedDetailUseCaseProvider);

  return usecase(
    postId,
  ).then((result) => result.fold((l) => throw l, (r) => r));
}
