import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../domain/entities/newsfeed_display.dart';
import '../viewmodels/newsfeed_list_viewmodel.dart';

class NewsfeedCard extends ConsumerWidget {
  const NewsfeedCard({
    super.key,
    required this.newsfeed,
    this.detailRouteName = RouteNames.newsfeedDetail,
  });

  final NewsfeedDisplay newsfeed;
  final String detailRouteName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print('newsfeed.commentsCount: ${newsfeed.commentsCount}');
    return InkWell(
      onTap: () {
        context.goNamed(
          detailRouteName,
          pathParameters: {'postId': newsfeed.postId},
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueGrey,
                    // authorAvatarUrl이 있으면 NetworkImage를, 없으면 Icon 표시
                    backgroundImage: newsfeed.authorAvatarUrl != null
                        ? CachedNetworkImageProvider(newsfeed.authorAvatarUrl!)
                        : null,
                    child: newsfeed.authorAvatarUrl == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsfeed.authorUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(newsfeed.postCreatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 제목
              Text(
                newsfeed.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              // imageUrl로 이미지 표시
              if (newsfeed.imageUrl != null) ...[
                Image.network(newsfeed.imageUrl!),
                const SizedBox(height: 8),
              ],

              // 내용
              Text(
                newsfeed.content,
                maxLines: 5, // 너무 길면 일부만 보여줌
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 32),

              // 좋아요 및 댓글 수
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      final notifier = ref.read(
                        newsfeedListViewModelProvider.notifier,
                      );
                      final success = await notifier.toggleLike(
                        newsfeed.postId,
                      );
                      if (!success && context.mounted) {
                        showErrorSnackbar(
                          context,
                          message: 'Failed to update like. Please try again.',
                        );
                      }
                    },
                    icon: Icon(
                      newsfeed.currentUserLiked
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined,
                      size: 18,
                      color: newsfeed.currentUserLiked
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(newsfeed.likesCount.toString()),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(newsfeed.commentsCount.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
