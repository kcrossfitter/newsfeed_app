import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/comment_list_viewmodel.dart';
import 'comment_card.dart';

class CommentSliver extends ConsumerWidget {
  const CommentSliver({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsState = ref.watch(commentListViewModelProvider(postId));

    return commentsState.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $error'))),
      data: (state) {
        if (state.comments.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 32),
              child: Center(child: Text('No comments yet.')),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= state.comments.length) {
                return !state.hasReachedMax
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              final comment = state.comments[index];
              return CommentCard(comment: comment);
            },
            childCount: state.hasReachedMax
                ? state.comments.length
                : state.comments.length + 1,
          ),
        );
      },
    );
  }
}
