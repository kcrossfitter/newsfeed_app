import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signup({
    required String email,
    required String password,
    required String username,
  });

  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();
}
