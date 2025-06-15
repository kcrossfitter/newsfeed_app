import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/newsfeed_display.dart';
import '../repositories/newsfeed_repository.dart';

class SearchNewsfeedsUseCase implements UseCase<List<NewsfeedDisplay>, String> {
  SearchNewsfeedsUseCase({required NewsfeedRepository newsfeedRepository})
    : _newsfeedRepository = newsfeedRepository;

  final NewsfeedRepository _newsfeedRepository;

  @override
  Future<Either<Failure, List<NewsfeedDisplay>>> call(String params) async {
    return await _newsfeedRepository.searchNewsfeeds(query: params);
  }
}
