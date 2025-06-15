import 'package:equatable/equatable.dart';

class Newsfeed extends Equatable {
  const Newsfeed({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props {
    return [
      id,
      authorId,
      title,
      content,
      imageUrl,
      likesCount,
      commentsCount,
      createdAt,
      updatedAt,
    ];
  }
}
