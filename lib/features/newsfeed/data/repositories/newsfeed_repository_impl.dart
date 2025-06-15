import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment_display.dart';
import '../../domain/entities/like_result.dart';
import '../../domain/entities/newsfeed_display.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../datasources/newsfeed_remote_data_source.dart';

class NewsfeedRepositoryImpl implements NewsfeedRepository {
  NewsfeedRepositoryImpl({
    required NewsfeedRemoteDataSource newsfeedRemoteDataSource,
    required SupabaseClient supabaseClient,
  }) : _newsfeedRemoteDataSource = newsfeedRemoteDataSource,
       _supabaseClient = supabaseClient;

  final NewsfeedRemoteDataSource _newsfeedRemoteDataSource;
  final SupabaseClient _supabaseClient;

  @override
  Future<Either<Failure, void>> createNewsfeed({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final authorId = _supabaseClient.auth.currentUser?.id;
      if (authorId == null) {
        return const Left(
          AuthenticationFailure(
            message: 'User is not authenticated. Cannot create newsfeed.',
          ),
        );
      }

      await _newsfeedRemoteDataSource.createNewsfeed(
        postId: postId,
        title: title,
        content: content,
        authorId: authorId,
        imageUrl: imageUrl,
      );

      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      // DataSource에서 던져진 Exception을 처리
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsfeedDisplay>>> getNewsfeeds({
    required int offset,
    required int limit,
  }) async {
    try {
      final newsfeeds = await _newsfeedRemoteDataSource.getNewsfeeds(
        offset: offset,
        limit: limit,
      );
      return Right(newsfeeds);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadNewsfeedImage({
    required File image,
    required String postId,
  }) async {
    try {
      final imageUrl = await _newsfeedRemoteDataSource.uploadNewfeedImage(
        image: image,
        postId: postId,
      );
      return Right(imageUrl);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNewsfeed({required String postId}) async {
    try {
      await _newsfeedRemoteDataSource.deleteNewsfeed(postId: postId);
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NewsfeedDisplay>> updateNewsfeed({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final updatedNewsfeed = await _newsfeedRemoteDataSource.updateNewsfeed(
        postId: postId,
        title: title,
        content: content,
        imageUrl: imageUrl,
      );
      return Right(updatedNewsfeed);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNewsfeedFolder({
    required String postId,
  }) async {
    try {
      // 이 작업은 실패하더라도 전체 삭제 흐름에 큰 영향을 주지 않으므로,
      // 에러를 반환하기보다 성공(Right)으로 처리하고 내부적으로 로그만 남길 수 있습니다.
      print('NewsfeedRepository.deleteNewsfeedFolder: (postId: $postId)');
      await _newsfeedRemoteDataSource.deleteNewsfeedFolder(postId: postId);
      return const Right(null);
    } catch (e) {
      // 여기서는 어떤 에러가 발생하든 Right(null)을 반환하여
      // DB 레코드 삭제 후의 흐름이 중단되지 않도록 합니다.
      print('deleteNewsfeedFolder failed, but proceeding: $e');
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<CommentDisplay>>> getComments({
    required String postId,
    required int offset,
    required int limit,
  }) async {
    try {
      final comments = await _newsfeedRemoteDataSource.getComments(
        postId: postId,
        offset: offset,
        limit: limit,
      );
      return Right(comments);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return const Left(
          AuthenticationFailure(message: 'User not authenticated.'),
        );
      }

      await _newsfeedRemoteDataSource.createComment(
        postId: postId,
        content: content,
        userId: userId,
      );
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    try {
      await _newsfeedRemoteDataSource.deleteComment(commentId: commentId);
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentDisplay>> updateComment({
    required String commentId,
    required String newContent,
  }) async {
    try {
      final updatedComment = await _newsfeedRemoteDataSource.updateComment(
        commentId: commentId,
        newContent: newContent,
      );
      return Right(updatedComment);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LikeResult>> toggleLike({
    required String postId,
  }) async {
    try {
      final likeResult = await _newsfeedRemoteDataSource.toggleLike(
        postId: postId,
      );
      // return Left(ServerFailure(message: 'intentional error'));
      return Right(likeResult);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsfeedDisplay>>> searchNewsfeeds({
    required String query,
  }) async {
    try {
      final newsfeeds = await _newsfeedRemoteDataSource.searchNewsfeeds(
        query: query,
      );
      return Right(newsfeeds);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NewsfeedDisplay>> getNewsfeedDetail({
    required String postId,
  }) async {
    try {
      final newsfeed = await _newsfeedRemoteDataSource.getNewsfeedDetail(
        postId: postId,
      );
      return Right(newsfeed);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
