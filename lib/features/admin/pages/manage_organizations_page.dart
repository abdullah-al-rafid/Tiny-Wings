import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../../core/widgets/app_image.dart';

class ManageOrganizationsPage extends ConsumerWidget {
  const ManageOrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Organizations'),
      ),
      body: organizationsAsync.when(
        data: (organizations) {
          if (organizations.isEmpty) {
            return const Center(child: Text('No organizations found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: organizations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final org = organizations[index];
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        image: org.imageUrl.isNotEmpty
                            ? DecorationImage(image: getAppImageProvider(org.imageUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: org.imageUrl.isEmpty
                          ? const Icon(Icons.business, color: AppColors.textSecondary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            org.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            org.location,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      onPressed: () => context.push('/admin/edit-organization/${org.id}'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
