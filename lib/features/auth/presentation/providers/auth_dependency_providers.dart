import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_providers.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/supabase_auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_dependency_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return SupabaseAuthRemoteDataSource(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

@riverpod
SignupUseCase signupUseCase(Ref ref) {
  return SignupUseCase(authRepository: ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(authRepository: ref.watch(authRepositoryProvider));
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(authRepository: ref.watch(authRepositoryProvider));
}
