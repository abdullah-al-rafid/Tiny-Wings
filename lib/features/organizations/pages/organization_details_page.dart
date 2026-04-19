import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/organization_providers.dart';
import '../../needs/providers/need_providers.dart';
import '../../../models/organization_model.dart';
import '../../../models/need_model.dart';
import '../../../models/subscription_model.dart';
import '../../../models/supporter_model.dart';
import '../../../core/widgets/app_image.dart';
import '../../sponsorships/providers/sponsorship_providers.dart';
import '../../../core/auth/auth_repository.dart';
import '../widgets/sponsorship_tier_card.dart';

class OrganizationDetailsPage extends ConsumerWidget {
  final String organizationId;

  const OrganizationDetailsPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(organizationDetailsProvider(organizationId));
    final needsAsync = ref.watch(needsByOrgProvider(organizationId));
    final supportersAsync = ref.watch(orgSupportersProvider(organizationId));
    final sponsorsAsync = ref.watch(orgSponsorsProvider(organizationId));
    final authData = ref.watch(authModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Details'),
      ),
      body: organizationAsync.when(
        data: (org) {
          if (org == null) {
            return const Center(child: Text('Organization not found'));
          }
          final needsList = needsAsync.value ?? [];
          final activeNeeds = needsList.where((n) => n.status != 'fulfilled').toList();
          final supportersList = supportersAsync.value ?? [];
          final activeSubs = (sponsorsAsync.value ?? []).where((s) => s.status == 'active').toList();
          
          return _buildContent(context, org, activeNeeds, supportersList, activeSubs, authData?.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildContent(BuildContext context, Organization org, List<Need> needs, List<Supporter> supporters, List<Subscription> activeSubscriptions, String? currentUserId) {
    
    bool isCurrentUserSponsor = currentUserId != null && activeSubscriptions.any((s) => s.donorId == currentUserId);


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover Image
          Container(
            height: 240,
            decoration: const BoxDecoration(
              color: AppColors.background,
            ),
            child: org.imageUrl.isNotEmpty
                ? AppImage(
                    imageUrl: org.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                    ),
                  )
                : const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        org.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (org.isVerified)
                      const Icon(Icons.verified, color: AppColors.primary, size: 28),
                  ],
                ),
                const SizedBox(height: 24),

                // Key Stats Section
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        child: Column(
                          children: [
                            Text(
                              '${org.totalChildren}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Children Supported', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // About Section
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  org.about,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),

                // Contact Section
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _ContactRow(
                  icon: Icons.location_on_outlined,
                  text: org.location,
                ),
                const SizedBox(height: 12),
                if (org.phone.isNotEmpty) ...[
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    text: org.phone,
                  ),
                  const SizedBox(height: 12),
                ],
                if (org.email.isNotEmpty) ...[
                  _ContactRow(
                    icon: Icons.email_outlined,
                    text: org.email,
                  ),
                  const SizedBox(height: 32),
                ],
                
                if (supporters.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Contributors',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.push('/organizations/$organizationId/supporters'),
                        child: const Text('View Full Ranking'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Monthly Sponsors Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.stars, color: AppColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text('Monthly Sponsors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...supporters.where((s) => s.isMonthly).take(3).map((s) {
                                Color tierColor;
                                IconData tierIcon;
                                if (s.totalAmount >= 5000) {
                                  tierColor = Colors.amber.shade900;
                                  tierIcon = Icons.workspace_premium;
                                } else if (s.totalAmount >= 2500) {
                                  tierColor = Colors.blueGrey.shade600;
                                  tierIcon = Icons.stars;
                                } else {
                                  tierColor = Colors.orange.shade800;
                                  tierIcon = Icons.emoji_events;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(tierIcon, color: tierColor, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(s.donorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            Text(
                                              s.rankTitle,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: tierColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if (!supporters.any((s) => s.isMonthly))
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('No active sponsors.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ),
                            ],
                          ),
                        ),
                        
                        // Divider
                        Container(
                          width: 1,
                          height: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),

                        // Top Donors Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.volunteer_activism, color: Colors.teal, size: 20),
                                  SizedBox(width: 8),
                                  Text('Top Donors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...supporters.where((s) => !s.isMonthly).take(3).map((s) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(s.donorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                      Text('৳${s.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if (!supporters.any((s) => !s.isMonthly))
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('No donations.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                if (isCurrentUserSponsor) ...[
                  AppCard(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.5)),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: AppColors.teal, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Active Sponsor', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal, fontSize: 16)),
                              Text('You are currently a monthly sponsor of this organization! Thank you.', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  Text(
                    'Sponsor this Organization',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SponsorshipTierCard(tierName: 'Bronze Tier', amount: 1000, org: org, color: Colors.orange.shade50),
                  const SizedBox(height: 12),
                  SponsorshipTierCard(tierName: 'Silver Tier', amount: 2500, org: org, color: Colors.grey.shade100),
                  const SizedBox(height: 12),
                  SponsorshipTierCard(tierName: 'Gold Tier', amount: 5000, org: org, color: Colors.amber.shade50, isPremium: true),
                  const SizedBox(height: 32),
                ],

                // Current Needs Section
                if (needs.isNotEmpty) ...[
                  Text(
                    'Current Needs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...needs.map((need) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        context.push('/donate', extra: {
                          'organizationId': org.id,
                          'needTitle': need.title,
                          'needAmount': need.targetQuantity > 0 ? '${need.targetQuantity} ${need.unit}' : need.quantityOrAmount,
                          'needCategory': need.category,
                          'needId': need.id,
                        });
                      },
                      child: _NeedItem(
                        title: need.title,
                        priority: need.priority,
                        subtitle: need.subtitle,
                        targetQuantity: need.targetQuantity,
                        fulfilledQuantity: need.fulfilledQuantity,
                        unit: need.unit,
                        quantityOrAmount: need.quantityOrAmount,
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: AppButton(
                style: AppButtonStyle.cta,
                text: 'Donate',
                onPressed: () => context.push('/donate', extra: {'organizationId': organizationId}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: AppButton(
                style: AppButtonStyle.secondary,
                text: 'Volunteer',
                onPressed: () => context.push('/volunteer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _NeedItem extends StatelessWidget {
  final String title;
  final String priority;
  final String subtitle;
  final double targetQuantity;
  final double fulfilledQuantity;
  final String unit;
  final String quantityOrAmount;

  const _NeedItem({
    required this.title,
    required this.priority,
    required this.subtitle,
    required this.targetQuantity,
    required this.fulfilledQuantity,
    required this.unit,
    required this.quantityOrAmount,
  });

  @override
  Widget build(BuildContext context) {
    bool isUrgent = priority.toLowerCase() == 'urgent';

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (targetQuantity > 0 || quantityOrAmount.isNotEmpty)
                Text(
                  targetQuantity > 0 
                      ? '${fulfilledQuantity.toString().replaceAll(RegExp(r'\.0$'), '')} / ${targetQuantity.toString().replaceAll(RegExp(r'\.0$'), '')} $unit fulfilled' 
                      : quantityOrAmount,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: targetQuantity > 0 && fulfilledQuantity > 0 ? AppColors.primary : null,
                    fontWeight: targetQuantity > 0 && fulfilledQuantity > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.coral.withValues(alpha: 0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUrgent ? AppColors.coral : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}