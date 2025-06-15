import '../../domain/entities/like_result.dart';

class LikeResultModel extends LikeResult {
  const LikeResultModel({required super.liked, required super.likesCount});

  factory LikeResultModel.fromMap(Map<String, dynamic> map) {
    return LikeResultModel(
      liked: map['liked'] as bool,
      likesCount: map['likes_count'] as int,
    );
  }
}
