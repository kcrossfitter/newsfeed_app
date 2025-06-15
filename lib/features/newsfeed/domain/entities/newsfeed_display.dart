import 'package:equatable/equatable.dart';

class NewsfeedDisplay extends Equatable {
  const NewsfeedDisplay({
    required this.postId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.postCreatedAt,
    required this.postUpdatedAt,
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.authorRole,
    required this.likesCount,
    required this.commentsCount,
    required this.currentUserLiked,
  });

  final String postId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime postCreatedAt;
  final DateTime postUpdatedAt;
  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String authorRole;
  final int likesCount;
  final int commentsCount;
  final bool currentUserLiked;

  @override
  List<Object?> get props {
    return [
      postId,
      title,
      content,
      imageUrl,
      postCreatedAt,
      postUpdatedAt,
      authorId,
      authorUsername,
      authorAvatarUrl,
      authorRole,
      likesCount,
      commentsCount,
      currentUserLiked,
    ];
  }

  NewsfeedDisplay copyWith({
    String? postId,
    String? title,
    String? content,
    String? imageUrl,
    DateTime? postCreatedAt,
    DateTime? postUpdatedAt,
    String? authorId,
    String? authorUsername,
    String? authorAvatarUrl,
    String? authorRole,
    int? likesCount,
    int? commentsCount,
    bool? currentUserLiked,
  }) {
    return NewsfeedDisplay(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      postCreatedAt: postCreatedAt ?? this.postCreatedAt,
      postUpdatedAt: postUpdatedAt ?? this.postUpdatedAt,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? authorAvatarUrl,
      authorRole: authorRole ?? this.authorRole,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      currentUserLiked: currentUserLiked ?? this.currentUserLiked,
    );
  }
}
