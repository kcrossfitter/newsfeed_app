import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/comment_list_viewmodel.dart';

class CommentInput extends ConsumerStatefulWidget {
  const CommentInput({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPosting = true);

    final success = await ref
        .read(commentListViewModelProvider(widget.postId).notifier)
        .addComment(content);

    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }

    if (mounted) {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _postComment(),
              ),
            ),
            IconButton(
              onPressed: _isPosting ? null : _postComment,
              icon: _isPosting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
