import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/comment_list_viewmodel.dart';
import 'comment_card.dart';

class CommentSection extends ConsumerStatefulWidget {
  const CommentSection({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false; // 중복 게시 방지

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref
          .read(commentListViewModelProvider(widget.postId).notifier)
          .fetchNextPage(widget.postId);
    }
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
    }

    // 실패 시 스낵바 등으로 사용자에게 피드백

    if (mounted) {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentListViewModelProvider(widget.postId));

    return Column(
      children: [
        // comment list
        commentState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (state) {
            if (state.comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No comments yet. Be the first')),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              shrinkWrap: true, // SingleChildScrollView 안에서 사용하기 위함
              physics: const NeverScrollableScrollPhysics(), // 부모 스크롤 사용
              itemCount: state.hasReachedMax
                  ? state.comments.length
                  : state.comments.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.comments.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comment = state.comments[index];
                return CommentCard(comment: comment);
              },
            );
          },
        ),

        const Divider(height: 1),

        // 댓글 입력창
        Padding(
          padding: const EdgeInsets.all(8),
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
      ],
    );
  }
}
