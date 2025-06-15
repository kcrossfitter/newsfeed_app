import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/comment_display_model.dart';
import '../models/like_result_model.dart';
import '../models/newsfeed_display_model.dart';
import 'newsfeed_remote_data_source.dart';

class SupabaseNewsfeedRemoteDataSource implements NewsfeedRemoteDataSource {
  SupabaseNewsfeedRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<void> createNewsfeed({
    required String postId,
    required String title,
    required String content,
    required String authorId,
    String? imageUrl,
  }) async {
    try {
      // 모델을 사용하지 않고 직접 맵을 생성하는 방식
      final newsfeedData = {
        'id': postId,
        'author_id': authorId,
        'title': title,
        'content': content,
        'image_url': imageUrl,
      };
      await _supabaseClient.from('newsfeeds').insert(newsfeedData);
    } on PostgrestException catch (e) {
      // RLS 위반이나 DB 제약조건 위반 등 DB 관련 에러 처리
      // 여기서는 구체적인 Failure로 변환하기 위해 에러를 다시 던집니다.
      // RepositoryImpl에서 이 에러를 잡아 Failure로 변환합니다.
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<NewsfeedDisplayModel>> getNewsfeeds({
    required int offset,
    required int limit,
  }) async {
    try {
      // page 1 -> range(0, 9)
      // page 2 -> range(10, 19)
      final to = offset + limit - 1;

      final newsfeedMaps = await _supabaseClient
          .from('newsfeed_display_view')
          .select()
          .order('post_created_at', ascending: false)
          .range(offset, to);
      return newsfeedMaps
          .map((nf) => NewsfeedDisplayModel.fromMap(nf))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> uploadNewfeedImage({
    required File image,
    required String postId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException('User not authenticated for image upload.');
      }

      // 고유한 파일 경로 생성 (e.g.: public/user_id/post_id/uuid.jpg)
      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageFileName = '${const Uuid().v4()}.$imageExtension';

      final imagePath = 'public/$userId/$postId/$imageFileName';

      // image upload
      await _supabaseClient.storage
          .from('newsfeed-images')
          .upload(imagePath, image);

      // upload 된 image의 public url 가져오기
      final imageUrl = _supabaseClient.storage
          .from('newsfeed-images')
          .getPublicUrl(imagePath);

      return imageUrl;
    } on StorageException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteNewsfeed({required String postId}) async {
    try {
      await _supabaseClient.from('newsfeeds').delete().match({'id': postId});
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<NewsfeedDisplayModel> updateNewsfeed({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      // 1. 'newsfeeds' 테이블의 데이터를 업데이트합니다.
      await _supabaseClient
          .from('newsfeeds')
          .update({'title': title, 'content': content, 'image_url': imageUrl})
          .match({'id': postId});

      // 2. 업데이트 된 최신 데이터를 'newsfeed_display_view'에서 조회하여 반환
      final updatedData = await _supabaseClient
          .from('newsfeed_display_view')
          .select()
          .eq('post_id', postId)
          .single();

      return NewsfeedDisplayModel.fromMap(updatedData);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteNewsfeedFolder({required String postId}) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      print(
        'SupbaseNewsfeedRemoteDataSource: (postId: $postId) (userId: $userId)',
      );
      if (userId == null) {
        throw const AuthException('User not authenticated for image deletion.');
      }
      final folderPath = 'public/$userId/$postId';

      // 1. 폴더 안의 모든 파일 목록을 가져옴
      final fileList = await _supabaseClient.storage
          .from('newsfeed-images')
          .list(path: folderPath);
      if (fileList.isEmpty) {
        return;
      }

      // 2. 파일 경로들의 리스트를 만듦
      final filesToRemove = fileList
          .map((file) => '$folderPath/${file.name}')
          .toList();

      print('filesToRemove: $filesToRemove');

      // 3. 파일들을 한번에 삭제
      await _supabaseClient.storage
          .from('newsfeed-images')
          .remove(filesToRemove);
    } on StorageException catch (e) {
      // Storage 에러는 무시하고 넘어갈 수도, 혹은 별도 로깅을 할 수도 있습니다.
      // DB 레코드가 주 데이터이므로, Storage 파일 삭제 실패가 전체 로직을 막아서는 안됩니다.
      print('Storage file deletion failed: ${e.message}');
    } catch (e) {
      print('An unknown error occurred during storage deletion: $e');
    }
  }

  @override
  Future<List<CommentDisplayModel>> getComments({
    required String postId,
    required int offset,
    required int limit,
  }) async {
    final to = offset + limit - 1;
    try {
      final commentMaps = await _supabaseClient
          .from('comment_display_view')
          .select()
          .eq('post_id', postId)
          .range(offset, to);
      return commentMaps
          .map((map) => CommentDisplayModel.fromMap(map))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> createComment({
    required String postId,
    required String content,
    required String userId,
  }) async {
    try {
      await _supabaseClient.from('comments').insert({
        'post_id': postId,
        'content': content,
        'user_id': userId,
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteComment({required String commentId}) async {
    try {
      await _supabaseClient.from('comments').delete().match({'id': commentId});
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<CommentDisplayModel> updateComment({
    required String commentId,
    required String newContent,
  }) async {
    try {
      // 1. comments table의 content update
      await _supabaseClient
          .from('comments')
          .update({'content': newContent})
          .match({'id': commentId});

      // 2. comment_display_view에서 업데이트 된 댓글의 최신 정보를 조회하여 반환
      final updatedCommentMap = await _supabaseClient
          .from('comment_display_view')
          .select()
          .eq('id', commentId)
          .single();

      return CommentDisplayModel.fromMap(updatedCommentMap);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<LikeResultModel> toggleLike({required String postId}) async {
    try {
      final result = await _supabaseClient.rpc(
        'handle_like',
        params: {'p_post_id': postId},
      );
      return LikeResultModel.fromMap(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<NewsfeedDisplayModel>> searchNewsfeeds({
    required String query,
  }) async {
    try {
      // 'search_newsfeeds' RPC 함수 호출
      final result = await _supabaseClient.rpc(
        'search_newsfeeds',
        params: {'p_search_query': query},
      );

      // RPC 결과는 List<dynamic>이므로, List<Map<String,dynamic>>으로 변환 필요
      final searchMaps = List<Map<String, dynamic>>.from(result as List);
      return searchMaps
          .map((map) => NewsfeedDisplayModel.fromMap(map))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<NewsfeedDisplayModel> getNewsfeedDetail({
    required String postId,
  }) async {
    try {
      final newsfeedDisplayModelMap = await _supabaseClient
          .from('newsfeed_display_view')
          .select()
          .eq('post_id', postId)
          .single();

      return NewsfeedDisplayModel.fromMap(newsfeedDisplayModelMap);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
