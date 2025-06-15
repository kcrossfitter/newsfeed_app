import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource profileRemoteDataSource,
  }) : _profileRemoteDataSource = profileRemoteDataSource;

  final ProfileRemoteDataSource _profileRemoteDataSource;

  @override
  Future<Either<Failure, Profile>> getProfile(String userId) async {
    try {
      final profile = await _profileRemoteDataSource.getProfile(userId);
      return Right(profile);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required File image,
    required String userId,
  }) async {
    try {
      print('File: $image, userId: $userId');
      final url = await _profileRemoteDataSource.uploadAvatar(
        image: image,
        userId: userId,
      );
      print('url: $url');
      return Right(url);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({
    required String userId,
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final updatedProfile = await _profileRemoteDataSource.updateProfile(
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
      );
      return Right(updatedProfile);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAvatar(String avatarUrl) async {
    try {
      await _profileRemoteDataSource.deleteAvatar(avatarUrl);
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'Request timed out. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
