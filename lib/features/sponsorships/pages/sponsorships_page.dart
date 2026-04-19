import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../organizations/providers/organization_providers.dart';

class SponsorshipsPage extends ConsumerStatefulWidget {
  const SponsorshipsPage({super.key});

  @override
  ConsumerState<SponsorshipsPage> createState() => _SponsorshipsPageState();
}

class _SponsorshipsPageState extends ConsumerState<SponsorshipsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsorships'),
      ),
      body: _buildOrgsTab(),
    );
  }


  Widget _buildOrgsTab() {
    final orgsAsync = ref.watch(organizationsProvider);

    return orgsAsync.when(
      data: (orgs) {
        if (orgs.isEmpty) return const Center(child: Text('No organizations found.'));

        return ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacing),
          itemCount: orgs.length,
          itemBuilder: (context, index) {
            final org = orgs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppCard(
                onTap: () => context.push('/organizations/${org.id}'),
                child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: org.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppImage(imageUrl: org.imageUrl, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.business, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(org.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(org.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.border),
                ],
              ),
            ),
          );
        },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}