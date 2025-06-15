import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/utils/ui_utils.dart';
import '../providers/newsfeed_dependency_providers.dart';
import '../viewmodels/comment_list_viewmodel.dart';
import '../viewmodels/newsfeed_list_viewmodel.dart';
import '../widgets/comment_card.dart';

class NewsfeedDetailPage extends ConsumerStatefulWidget {
  const NewsfeedDetailPage({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<NewsfeedDetailPage> createState() => _NewsfeedDetailPageState();
}

class _NewsfeedDetailPageState extends ConsumerState<NewsfeedDetailPage> {
  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  bool _isPosting = false;

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
        _scrollController.position.maxScrollExtent - 200) {
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
      // 댓글 추가 성공 시 스크롤을 맨 위로 & 모든 데이터 새로 고침
      _scrollController.jumpTo(0);
      // 2. 댓글 목록 새로 고침
      ref.invalidate(commentListViewModelProvider(widget.postId));
      ref.invalidate(newsfeedDetailProvider(widget.postId));

      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
    if (mounted) {
      setState(() => _isPosting = false);
    }
  }

  Widget _buildCommentList() {
    final commentsState = ref.watch(
      commentListViewModelProvider(widget.postId),
    );
    return commentsState.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $error'))),
      data: (state) {
        if (state.comments.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text('No comments yet.')),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // 다음 페이지 로딩 인디케이터
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

  @override
  Widget build(BuildContext context) {
    // 페이지의 모든 데이터는 newsfeedDetailProvider에서 가져옴
    final newsfeedAsyncValue = ref.watch(newsfeedDetailProvider(widget.postId));

    return newsfeedAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(err.toString())),
      ),
      data: (newsfeed) {
        final currentUser = ref.watch(authStateStreamProvider).valueOrNull;
        final canModify =
            (currentUser?.userMetadata?['role'] == 'admin' &&
            currentUser?.id == newsfeed.authorId);

        return Scaffold(
          appBar: AppBar(
            title: Text(newsfeed.title, style: const TextStyle(fontSize: 18)),
            actions: [
              if (canModify)
                IconButton(
                  onPressed: () async {
                    await context.pushNamed(
                      RouteNames.newsfeedEdit,
                      pathParameters: {'postId': widget.postId},
                      extra: newsfeed,
                    );
                    ref.invalidate(newsfeedDetailProvider(widget.postId));
                    ref.invalidate(newsfeedListViewModelProvider);
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (canModify)
                IconButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                            'Are you sure you want to delete this newsfeed?',
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
                        );
                      },
                    );

                    if (confirmed == true) {
                      await ref
                          .read(newsfeedListViewModelProvider.notifier)
                          .deleteNewsfeed(widget.postId);
                      // .deleteNewsfeed(widget.newsfeed.postId);
                      // 성공적으로 호출 후 목록으로 돌아가기
                      if (context.mounted) context.pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Newsfeed',
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(newsfeedDetailProvider(widget.postId));
              ref.invalidate(commentListViewModelProvider(widget.postId));
            },
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage:
                                        newsfeed.authorAvatarUrl != null
                                        ? CachedNetworkImageProvider(
                                            newsfeed.authorAvatarUrl!,
                                          )
                                        : null,
                                    child: newsfeed.authorAvatarUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(newsfeed.authorUsername),
                                      Text(
                                        DateFormat(
                                          'yyyy-MM-dd HH:mm',
                                        ).format(newsfeed.postCreatedAt),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (newsfeed.imageUrl != null &&
                                  newsfeed.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(newsfeed.imageUrl!),
                                ),
                              const SizedBox(height: 24),
                              Text(
                                newsfeed.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                newsfeed.content,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final notifier = ref.read(
                                    newsfeedListViewModelProvider.notifier,
                                  );
                                  final success = await notifier.toggleLike(
                                    widget.postId,
                                  );
                                  if (!success && context.mounted) {
                                    showErrorSnackbar(
                                      context,
                                      message:
                                          'Failed to update like. Please try again.',
                                    );
                                  }
                                },
                                icon: Icon(
                                  newsfeed.currentUserLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: newsfeed.currentUserLiked
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              Text(newsfeed.likesCount.toString()),
                              const SizedBox(width: 16),
                              const Icon(Icons.mode_comment_outlined, size: 24),
                              Text(newsfeed.commentsCount.toString()),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: Divider(height: 1)),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: _buildCommentList(),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
