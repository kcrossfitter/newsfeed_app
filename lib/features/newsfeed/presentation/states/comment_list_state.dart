import 'package:equatable/equatable.dart';

import '../../domain/entities/comment_display.dart';

class CommentListState extends Equatable {
  const CommentListState({
    this.comments = const [],
    this.hasReachedMax = false,
  });

  final List<CommentDisplay> comments;
  final bool hasReachedMax;

  @override
  List<Object> get props => [comments, hasReachedMax];

  CommentListState copyWith({
    List<CommentDisplay>? comments,
    bool? hasReachedMax,
  }) {
    return CommentListState(
      comments: comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
