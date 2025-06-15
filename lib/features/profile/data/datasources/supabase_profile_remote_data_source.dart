import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/profile_model.dart';
import 'profile_remote_data_source.dart';

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  SupabaseProfileRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final profileMap = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromMap(profileMap);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar({
    required File image,
    required String userId,
  }) async {
    try {
      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageFileName = '${const Uuid().v4()}.$imageExtension';
      final imagePath = 'public/$userId/avatar/$imageFileName';
      print('imagePath: $imagePath');

      await _supabaseClient.storage.from('avatars').upload(imagePath, image);
      print('upload success');
      return _supabaseClient.storage.from('avatars').getPublicUrl(imagePath);
    } on StorageException catch (e) {
      print('StorageException: $e');
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String userId,
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final updatedProfileMap = await _supabaseClient
          .from('profiles')
          .update({'username': username, 'avatar_url': avatarUrl})
          .eq('id', userId)
          .select()
          .single();
      return ProfileModel.fromMap(updatedProfileMap);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final Uri uri = Uri.parse(avatarUrl);
      // bucket-id/public 이후
      final path = uri.pathSegments.sublist(3).join('/');
      await _supabaseClient.storage.from('avatars').remove([path]);
    } catch (e) {
      // 실패해도 exception을 던지지 않음 (DB 업데이트가 더 중요)
      print('Failed to delete avatar from storage: $e');
    }
  }
}
