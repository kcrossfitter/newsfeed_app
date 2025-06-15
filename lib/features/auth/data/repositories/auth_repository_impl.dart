import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource authRemoteDataSource})
    : _authRemoteDataSource = authRemoteDataSource;

  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  Future<Either<Failure, void>> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _authRemoteDataSource.signup(
        email: email,
        password: password,
        username: username,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'The request time has expired.'),
      );
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'An unknown error occurred during sign-up.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      // remoteDataSource.login()은 성공 시 User 객체를 반환하지만,
      // 이 Repository 메소드는 void를 반환하므로 User 객체는 사용하지 않습니다.
      // 로그인 행위 자체가 성공적으로 완료되었음을 Right(null)로 알립니다.
      await _authRemoteDataSource.login(email: email, password: password);
      return const Right(null);
    } on AuthException catch (e) {
      // Supabase AuthException을 AuthenticationFailure로 변환
      // e.message (예: "Invalid login credentials") 등을 활용
      return Left(AuthenticationFailure(message: e.message));
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'The request time has expired.'),
      );
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'An unknown error occurred during login.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _authRemoteDataSource.logout();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(
        AuthenticationFailure(
          message: 'Error occurred while logging out: ${e.message}',
        ),
      );
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'The request time has expired.'),
      );
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'An unknown error occurred during logout.'),
      );
    }
  }
}
