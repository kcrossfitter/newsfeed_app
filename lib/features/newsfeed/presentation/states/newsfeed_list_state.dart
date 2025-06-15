import 'package:equatable/equatable.dart';

import '../../domain/entities/newsfeed_display.dart';

class NewsfeedListState extends Equatable {
  const NewsfeedListState({
    this.newsfeeds = const [],
    this.hasReachedMax = false,
  });

  final List<NewsfeedDisplay> newsfeeds;
  final bool hasReachedMax; // 더 이상 불러올 데이터가 없는지 여부

  @override
  List<Object> get props => [newsfeeds, hasReachedMax];

  NewsfeedListState copyWith({
    List<NewsfeedDisplay>? newsfeeds,
    bool? hasReachedMax,
  }) {
    return NewsfeedListState(
      newsfeeds: newsfeeds ?? this.newsfeeds,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
