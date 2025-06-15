import '../../domain/entities/newsfeed.dart';

class NewfeedModel extends Newsfeed {
  const NewfeedModel({
    required super.id,
    required super.authorId,
    required super.title,
    required super.content,
    super.imageUrl,
    required super.likesCount,
    required super.commentsCount,
    required super.createdAt,
    required super.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'author_id': authorId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // insert 시에는 author_id, title, content만 필요합니다.
  // 이들을 모아 toMapForInsert와 같은 별도 메서드를 만들 수도 있습니다.
  Map<String, dynamic> toMapForInsert({required String authorId}) {
    return <String, dynamic>{
      'author_id': authorId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
    };
  }
}
