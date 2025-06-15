import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile(String userId);

  Future<Either<Failure, Profile>> updateProfile({
    required String userId,
    required String username,
    String? avatarUrl,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required File image,
    required String userId,
  });

  Future<Either<Failure, void>> deleteAvatar(String avatarUrl);
}
