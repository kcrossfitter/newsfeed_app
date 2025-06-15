import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.userId,
    required this.username,
    this.originalAvatarUrl,
    this.newAvatarFile,
    this.avatarWasRemoved = false,
  });

  final String userId;
  final String username;
  final String? originalAvatarUrl;
  final File? newAvatarFile;
  final bool avatarWasRemoved;

  @override
  List<Object?> get props => [
    userId,
    username,
    originalAvatarUrl,
    newAvatarFile,
    avatarWasRemoved,
  ];

  @override
  String toString() {
    return 'UpdateProfileParams(userId: $userId, username: $username, originalAvatarUrl: $originalAvatarUrl, newAvatarFile: $newAvatarFile, avatarWasRemoved: $avatarWasRemoved)';
  }
}

class UpdateProfileUseCase implements UseCase<Profile, UpdateProfileParams> {
  UpdateProfileUseCase({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    try {
      String? finalAvatarUrl = params.originalAvatarUrl;

      print('params: $params');

      // 시나리오 1: 새 아바타 이미지로 교체하는 경우
      if (params.newAvatarFile != null) {
        // 1a. 기존 아바타가 있으면 먼저 삭제
        if (params.originalAvatarUrl != null) {
          await _profileRepository.deleteAvatar(params.originalAvatarUrl!);
        }
        // 1b. 새 아바타 업로드
        final uploadResult = await _profileRepository.uploadAvatar(
          image: params.newAvatarFile!,
          userId: params.userId,
        );
        // 1c. 업로드 실패 시 에러 반환
        finalAvatarUrl = uploadResult.fold((failure) => null, (url) => url);
        print('finalAvatarUrl after upload: $finalAvatarUrl');

        if (finalAvatarUrl == null) {
          return const Left(
            ServerFailure(message: 'Failed to upload new avatar.'),
          );
        }
      }
      // 시나리오 2: 기존 아바타를 제거만 하는 경우
      else if (params.avatarWasRemoved && params.originalAvatarUrl != null) {
        await _profileRepository.deleteAvatar(params.originalAvatarUrl!);
        finalAvatarUrl = null;
      }

      // 최종적으로 프로필 정보 DB 업데이트
      return await _profileRepository.updateProfile(
        userId: params.userId,
        username: params.username,
        avatarUrl: finalAvatarUrl,
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
