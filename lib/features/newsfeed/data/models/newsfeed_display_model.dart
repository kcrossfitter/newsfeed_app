import '../../domain/entities/newsfeed_display.dart';

class NewsfeedDisplayModel extends NewsfeedDisplay {
  const NewsfeedDisplayModel({
    required super.postId,
    required super.title,
    required super.content,
    super.imageUrl,
    required super.postCreatedAt,
    required super.postUpdatedAt,
    required super.authorId,
    required super.authorUsername,
    super.authorAvatarUrl,
    required super.authorRole,
    required super.likesCount,
    required super.commentsCount,
    required super.currentUserLiked,
  });

  factory NewsfeedDisplayModel.fromMap(Map<String, dynamic> map) {
    return NewsfeedDisplayModel(
      postId: map['post_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      imageUrl: map['image_url'] as String?,
      postCreatedAt: DateTime.parse(map['post_created_at'] as String),
      postUpdatedAt: DateTime.parse(map['post_updated_at'] as String),
      authorId: map['author_id'] as String,
      authorUsername: map['author_username'] as String,
      authorAvatarUrl: map['author_avatar_url'] as String?,
      authorRole: map['author_role'] as String,
      likesCount: map['likes_count'] as int,
      commentsCount: map['comments_count'] as int,
      currentUserLiked: map['current_user_liked'] as bool,
    );
  }
}
