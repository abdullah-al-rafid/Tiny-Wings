import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/organization_providers.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/localization/app_localization.dart';
import 'dart:ui';

class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(filteredOrganizationsProvider);
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t['organizations'] ?? 'Organizations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF3E8FF), Color(0xFFE0E7FF), Color(0xFFFAE8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppTheme.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                            ),
                            child: TextField(
                              onChanged: (value) => ref.read(organizationSearchQueryProvider.notifier).state = value,
                              decoration: InputDecoration(
                                hintText: t['search_orgs'] ?? 'Search organizations...',
                                hintStyle: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.4)),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(context, t['all'] ?? 'All', isSelected: true),
                            const SizedBox(width: 8),
                            _buildFilterChip(context, t['dhaka'] ?? 'Dhaka', isSelected: false),
                            const SizedBox(width: 8),
                            _buildFilterChip(context, t['verified'] ?? 'Verified', isSelected: false),
                            const SizedBox(width: 8),
                            _buildFilterChip(context, t['urgent'] ?? 'Urgent', isSelected: false),
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
                        return Center(
                          child: Text(t['no_organizations_found'] ?? 'No organizations found'),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A8A) : Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _OrganizationCard extends ConsumerWidget {
  final Organization organization;
  final VoidCallback onDetailsPressed;

  const _OrganizationCard({
    required this.organization,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: organization.imageUrl.isNotEmpty
                      ? AppImage(
                          imageUrl: organization.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, _) => const Icon(
                            Icons.business_rounded,
                            size: 48,
                            color: Color(0xFF3B82F6),
                          ),
                        )
                      : const Icon(Icons.business_rounded, size: 48, color: Color(0xFF3B82F6)),
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
                          if (organization.status == VerificationStatus.verified)
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
                        text: t['view_details'] ?? 'View Details',
                        onPressed: onDetailsPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
