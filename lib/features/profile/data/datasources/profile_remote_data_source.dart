import 'dart:io';

import '../models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);

  Future<ProfileModel> updateProfile({
    required String userId,
    required String username,
    String? avatarUrl,
  });

  Future<String> uploadAvatar({required File image, required String userId});

  Future<void> deleteAvatar(String avatarUrl);
}
