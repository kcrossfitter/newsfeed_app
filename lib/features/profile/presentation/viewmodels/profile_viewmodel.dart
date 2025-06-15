import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../providers/profile_dependency_providers.dart';

part 'profile_viewmodel.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  FutureOr<Profile?> build() async {
    final userId = ref.watch(authStateStreamProvider).valueOrNull?.id;
    if (userId == null) return null;
    final getProfileUseCase = ref.read(getProfileUseCaseProvider);
    final result = await getProfileUseCase(userId);
    return result.fold((failure) => throw failure, (profile) => profile);
  }

  Future<void> updateProfile({
    required String username,
    File? newAvatarFile,
    bool avatarWasRemoved = false,
  }) async {
    final originalProfile = state.valueOrNull;
    if (originalProfile == null) return;

    state = const AsyncLoading();

    final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    final params = UpdateProfileParams(
      userId: originalProfile.id,
      username: username,
      originalAvatarUrl: originalProfile.avatarUrl,
      newAvatarFile: newAvatarFile,
      avatarWasRemoved: avatarWasRemoved,
    );
    final result = await updateProfileUseCase(params);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (updatedProfile) {
        ref.invalidateSelf();
      },
    );
  }
}
