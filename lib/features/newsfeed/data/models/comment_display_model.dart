import '../../domain/entities/comment_display.dart';

class CommentDisplayModel extends CommentDisplay {
  const CommentDisplayModel({
    required super.id,
    required super.postId,
    required super.content,
    required super.createdAt,
    required super.authorId,
    required super.authorUsername,
    super.authorAvatarUrl,
  });

  factory CommentDisplayModel.fromMap(Map<String, dynamic> map) {
    return CommentDisplayModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      authorId: map['author_id'] as String,
      authorUsername: map['author_username'] as String,
      authorAvatarUrl: map['author_avatar_url'] as String?,
    );
  }
}
