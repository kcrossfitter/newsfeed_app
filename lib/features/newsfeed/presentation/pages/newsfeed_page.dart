import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../auth/presentation/providers/auth_dependency_providers.dart';

class NewsfeedPage extends ConsumerWidget {
  const NewsfeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewsFeed'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await ref
                  .read(logoutUseCaseProvider)
                  .call(const NoParams());
              result.fold((failure) {
                showErrorSnackbar(
                  context,
                  message: 'Logout Failure: ${failure.message}',
                );
              }, (_) {});
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Newsfeed')),
    );
  }
}
