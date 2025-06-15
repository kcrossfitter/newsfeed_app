import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/datasources/supabase_profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_dependency_providers.g.dart';

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  return SupabaseProfileRemoteDataSource(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    profileRemoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
}

@riverpod
GetProfileUseCase getProfileUseCase(Ref ref) {
  return GetProfileUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
  );
}

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) {
  return UpdateProfileUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
  );
}
