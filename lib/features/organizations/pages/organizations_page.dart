import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/organization_providers.dart';
import '../../../models/organization_model.dart';
import '../../../core/widgets/app_image.dart';

class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(filteredOrganizationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(AppTheme.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organizations',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) => 
                        ref.read(organizationSearchQueryProvider.notifier).state = value,
                    decoration: const InputDecoration(
                      hintText: 'Search organizations...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          'All',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        _buildFilterChip(context, 'Dhaka', isSelected: true),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Verified', isSelected: true),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Urgent', isSelected: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: organizationsAsync.when(
                data: (organizations) {
                  if (organizations.isEmpty) {
                    return const Center(
                      child: Text('No organizations found'),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.all(AppTheme.spacing),
                    itemCount: organizations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final org = organizations[index];
                      return _OrganizationCard(
                        organization: org,
                        onDetailsPressed: () {
                          context.push('/organizations/${org.id}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) {
                  final errorStr = error.toString().toLowerCase();
                  final isPermissionDenied = errorStr.contains('permission deni');
                  
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.coral),
                          const SizedBox(height: 16),
                          Text(
                            isPermissionDenied 
                              ? 'Access Denied' 
                              : 'Oops! Something went wrong',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPermissionDenied
                              ? 'Please verify your Firebase Realtime Database rules. They should allow reading from the "organizations" path.'
                              : '$error',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (isPermissionDenied) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Try setting your rules to:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '{ "rules": { ".read": true, ".write": "auth != null" } }',
                                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final Organization organization;
  final VoidCallback onDetailsPressed;

  const _OrganizationCard({
    required this.organization,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            color: AppColors.background,
            child: organization.imageUrl.isNotEmpty
                ? AppImage(
                    imageUrl: organization.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => const Icon(
                      Icons.business,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  )
                : const Icon(Icons.business, size: 48, color: AppColors.textSecondary),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        organization.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (organization.isVerified)
                      const Icon(Icons.verified, color: AppColors.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  organization.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  organization.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),
                AppButton(
                  style: AppButtonStyle.secondary,
                  text: 'View Details',
                  onPressed: onDetailsPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}