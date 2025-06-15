import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../domain/entities/comment_display.dart';
import '../viewmodels/comment_list_viewmodel.dart';

class CommentCard extends ConsumerWidget {
  const CommentCard({super.key, required this.comment});

  final CommentDisplay comment;

  void _showEditCommentDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLines: null, // 여러 줄 입력 가능
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newContent = textController.text.trim();
                if (newContent.isNotEmpty) {
                  await ref
                      .read(
                        commentListViewModelProvider(comment.postId).notifier,
                      )
                      .updateComment(
                        commentId: comment.id,
                        newContent: newContent,
                      );
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateStreamProvider).valueOrNull;
    // 수정은 본인만 가능
    final bool canEdit = currentUser?.id == comment.authorId;
    // 삭제는 본인 또는 관리자가 가능
    final bool canDelete =
        (currentUser?.id == comment.authorId) ||
        (currentUser?.userMetadata?['role'] == 'admin');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: comment.authorAvatarUrl != null
                ? CachedNetworkImageProvider(comment.authorAvatarUrl!)
                : null,
            child: comment.authorAvatarUrl == null
                ? const Icon(Icons.person, size: 18, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorUsername,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MM-dd HH:mm').format(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content),
              ],
            ),
          ),
          if (canEdit)
            IconButton(
              onPressed: () => _showEditCommentDialog(context, ref),
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
          //--- 삭제 버튼 추가 ---
          if (canDelete)
            IconButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                      'Are you sure you want to delete this comment?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref
                      .read(
                        commentListViewModelProvider(comment.postId).notifier,
                      )
                      .deleteComment(comment.id);
                }
              },
              icon: const Icon(Icons.delete_forever_outlined, size: 20),
            ),
        ],
      ),
    );
  }
}
