import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/admin_providers.dart';
import '../../settings/providers/support_providers.dart';
import '../../../core/services/db_initializer.dart';
import '../../organizations/data/organization_repository.dart';
import '../../profile/data/user_repository.dart';
import '../../needs/data/need_repository.dart';
import '../../volunteering/data/volunteer_repository.dart';
import '../../donations/data/donation_repository.dart';
import '../../volunteering/data/application_repository.dart';
import '../../notifications/data/notification_repository.dart';
import '../../../core/api/firebase_providers.dart';
import '../../settings/data/support_repository.dart';
import '../../sponsorships/data/sponsorship_repository.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  String selectedCategory = 'Food';
  final List<String> categories = ['Food', 'Clothing', 'Toys', 'Books', 'Medical', 'Other'];
  bool _isSeeding = false;

  Future<void> _handleSeed() async {
    setState(() => _isSeeding = true);
    try {
      final seeder = DatabaseInitializer(
        orgRepo: ref.read(organizationRepositoryProvider),
        userRepo: ref.read(userRepositoryProvider),
        needRepo: ref.read(needRepositoryProvider),
        volunteerRepo: ref.read(volunteerRepositoryProvider),
        donationRepo: ref.read(donationRepositoryProvider),
        applicationRepo: ref.read(applicationRepositoryProvider),
        notificationRepo: ref.read(notificationRepositoryProvider),
        sponsorshipRepo: ref.read(sponsorshipRepositoryProvider),
        supportRepo: ref.read(supportRepositoryProvider),
        firestore: ref.read(firestoreProvider),
      );
      await seeder.initializeProductionData();
      ref.invalidate(adminStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Production Database Initialized!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seeding failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: statsAsync.when(
        data: (stats) {
          final pendingCount = stats.allDonations.where((d) => d.status == 'pending').length;
          final feedbackAsync = ref.watch(allAdminTicketsProvider);
          final feedbackCount = feedbackAsync.value?.where((t) => t.status == 'pending').length ?? 0;
        
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatOverview(stats),
              const SizedBox(height: 32),

              _buildSectionHeader('Management'),
              const SizedBox(height: 16),
              _buildAdminAction(
                icon: Icons.business_outlined,
                title: 'Add Organization',
                subtitle: 'Create a new orphanage or charity profile',
                onTap: () => context.push('/admin/add-organization'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.settings_applications_outlined,
                title: 'Manage Organizations',
                subtitle: 'Edit or remove existing organizations',
                onTap: () => context.push('/admin/manage-organizations'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.add_box_outlined,
                title: 'Add Need',
                subtitle: 'Create a new request for an organization',
                onTap: () => context.push('/admin/add-need'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.volunteer_activism_outlined,
                title: 'Verify Applications',
                subtitle: 'Review donor and volunteer requests',
                badgeCount: pendingCount,
                onTap: () => context.push('/admin/verify-donations'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.assignment_ind_outlined,
                title: 'Verify Org Applications',
                subtitle: 'Review new orphanage/volunteer group signups',
                onTap: () => context.push('/admin/verify-organizations'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.report_problem_outlined,
                title: 'Pending Needs',
                subtitle: 'Review and approve organization needs',
                onTap: () => context.push('/admin/pending-needs'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.forum_outlined,
                title: 'User Feedback & Suggestions',
                subtitle: 'Respond to user complaints and suggestions',
                badgeCount: feedbackCount,
                onTap: () => context.push('/admin/feedback'),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Sponsorship & Circulars'),
              const SizedBox(height: 16),
              _buildAdminAction(
                icon: Icons.child_care_rounded,
                title: 'Add Child Profile',
                subtitle: 'Post a new sponsorship circular for a child',
                onTap: () => context.push('/sponsorships/add-child'),
              ),
              const SizedBox(height: 12),
              _buildAdminAction(
                icon: Icons.assignment_rounded,
                title: 'Manage Volunteer Circulars',
                subtitle: 'Edit or remove existing volunteer opportunities',
                onTap: () => context.push('/opportunity-board'),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('System Tools'),
              const SizedBox(height: 16),
              AppCard(
                onTap: _isSeeding ? null : _handleSeed,
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple.shade400),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Initialize Production Data', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Replace existing data with authentic Bangladeshi entities',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (_isSeeding)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Icon(Icons.play_arrow, color: Colors.grey.shade400),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading stats: $e')),
      ),
    );
  }

  Widget _buildStatOverview(AdminStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSmallStat('Direct Money', '৳${stats.totalMoney.toStringAsFixed(0)}', AppColors.teal)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallStat('Items Value', '৳${stats.itemsWorth.toStringAsFixed(0)}', AppColors.coral)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSmallStat('Verified Total Impact', '৳${stats.totalImpact.toStringAsFixed(0)}', AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallStat('Total Users', '${stats.totalUsers}', AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value, Color color) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildAdminAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount > 0)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              decoration: const BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          const Icon(Icons.chevron_right, color: AppColors.border),
        ],
      ),
    );
  }
}
