import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../auth/presentation/providers/auth_dependency_providers.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouteNames.profileEdit);
            },
            icon: const Icon(Icons.edit),
          ),
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
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile Not Found.'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: (profile.avatarUrl != null)
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: (profile.avatarUrl == null)
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  profile.username,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${profile.role}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
