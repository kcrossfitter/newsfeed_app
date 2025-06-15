import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment_display.dart';
import '../entities/like_result.dart';
import '../entities/newsfeed_display.dart';

abstract interface class NewsfeedRepository {
  Future<Either<Failure, void>> createNewsfeed({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<Either<Failure, List<NewsfeedDisplay>>> getNewsfeeds({
    required int offset,
    required int limit,
  });

  Future<Either<Failure, String>> uploadNewsfeedImage({
    required File image,
    required String postId,
  });

  Future<Either<Failure, void>> deleteNewsfeed({required String postId});

  Future<Either<Failure, NewsfeedDisplay>> updateNewsfeed({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<Either<Failure, void>> deleteNewsfeedFolder({required String postId});

  Future<Either<Failure, List<CommentDisplay>>> getComments({
    required String postId,
    required int offset,
    required int limit,
  });

  Future<Either<Failure, void>> createComment({
    required String postId,
    required String content,
  });

  Future<Either<Failure, void>> deleteComment({required String commentId});

  Future<Either<Failure, CommentDisplay>> updateComment({
    required String commentId,
    required String newContent,
  });

  Future<Either<Failure, LikeResult>> toggleLike({required String postId});

  Future<Either<Failure, List<NewsfeedDisplay>>> searchNewsfeeds({
    required String query,
  });

  Future<Either<Failure, NewsfeedDisplay>> getNewsfeedDetail({
    required String postId,
  });
}
