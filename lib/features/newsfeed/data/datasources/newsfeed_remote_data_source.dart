import 'dart:io';

import '../models/comment_display_model.dart';
import '../models/like_result_model.dart';
import '../models/newsfeed_display_model.dart';

abstract interface class NewsfeedRemoteDataSource {
  Future<void> createNewsfeed({
    required String postId,
    required String title,
    required String content,
    required String authorId,
    String? imageUrl,
  });

  Future<List<NewsfeedDisplayModel>> getNewsfeeds({
    required int offset,
    required int limit,
  });

  Future<String> uploadNewfeedImage({
    required File image,
    required String postId,
  });

  Future<void> deleteNewsfeed({required String postId});

  Future<NewsfeedDisplayModel> updateNewsfeed({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<void> deleteNewsfeedFolder({required String postId});

  Future<List<CommentDisplayModel>> getComments({
    required String postId,
    required int offset,
    required int limit,
  });

  Future<void> createComment({
    required String postId,
    required String content,
    required String userId,
  });

  Future<void> deleteComment({required String commentId});

  Future<CommentDisplayModel> updateComment({
    required String commentId,
    required String newContent,
  });

  // RPC는 성공/실패만 중요하므로 void로 단순화
  Future<LikeResultModel> toggleLike({required String postId});

  Future<List<NewsfeedDisplayModel>> searchNewsfeeds({required String query});

  Future<NewsfeedDisplayModel> getNewsfeedDetail({required String postId});
}
