import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/newsfeed_display.dart';
import '../repositories/newsfeed_repository.dart';

class GetNewsfeedParams extends Equatable {
  const GetNewsfeedParams({required this.offset, this.limit = 5});

  final int offset;
  final int limit;

  @override
  List<Object> get props => [offset, limit];
}

class GetNewsfeedsUseCase
    implements UseCase<List<NewsfeedDisplay>, GetNewsfeedParams> {
  GetNewsfeedsUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, List<NewsfeedDisplay>>> call(
    GetNewsfeedParams params,
  ) async {
    return await _newsfeedRepository.getNewsfeeds(
      offset: params.offset,
      limit: params.limit,
    );
  }
}
