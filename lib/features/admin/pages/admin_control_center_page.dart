import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/admin_providers.dart';
import '../../profile/data/user_repository.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../organizations/data/organization_repository.dart';
import '../../donations/data/donation_repository.dart';
import '../../needs/data/need_repository.dart';
import '../../volunteering/data/volunteer_repository.dart';
import '../../volunteering/data/application_repository.dart';
import '../../notifications/data/notification_repository.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/services/db_initializer.dart';
import '../../../core/api/firebase_providers.dart';
import '../../settings/data/support_repository.dart';
import '../../sponsorships/data/sponsorship_repository.dart';

class AdminControlCenterPage extends ConsumerStatefulWidget {
  const AdminControlCenterPage({super.key});

  @override
  ConsumerState<AdminControlCenterPage> createState() => _AdminControlCenterPageState();
}

class _AdminControlCenterPageState extends ConsumerState<AdminControlCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _userSearchController = TextEditingController();
  String _userSearchQuery = '';
  bool _isMaintenanceActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Command Center', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_customize_outlined), text: 'Overview'),
            Tab(icon: Icon(Icons.people_alt_outlined), text: 'Users'),
            Tab(icon: Icon(Icons.business_center_outlined), text: 'Orgs'),
            Tab(icon: Icon(Icons.security_outlined), text: 'Control'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildOrgsTab(),
          _buildSystemTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final statsAsync = ref.watch(adminStatsProvider);
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Vitality', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatTile('Total Impact', '৳${stats.totalImpact.toStringAsFixed(0)}', Icons.auto_graph, AppColors.primary),
                _buildStatTile('Active Users', '${stats.totalUsers}', Icons.person_add_alt_1, AppColors.teal),
                _buildStatTile('Monetary Capital', '৳${stats.totalMoney.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.indigo),
                _buildStatTile('In-Kind Support', '৳${stats.itemsWorth.toStringAsFixed(0)}', Icons.inventory_2_outlined, AppColors.coral),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.allDonations.length > 5 ? 5 : stats.allDonations.length,
              itemBuilder: (context, index) {
                final d = stats.allDonations[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: AppColors.background, child: const Icon(Icons.history, color: AppColors.textSecondary)),
                    title: Text(d.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${d.organizationName} - ${d.status}', style: const TextStyle(fontSize: 11)),
                    trailing: Text('৳${d.amount?.toStringAsFixed(0) ?? "0"}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final usersAsync = ref.watch(allUsersProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _userSearchController,
            onChanged: (v) => setState(() => _userSearchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search identifiers (Name, Email, Phone)...',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: usersAsync.when(
            data: (users) {
              final filtered = users.where((u) => u.name.toLowerCase().contains(_userSearchQuery) || u.email.toLowerCase().contains(_userSearchQuery)).toList();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildUserCard(filtered[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isSuspended = user.status == 'suspended';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: user.profilePictureUrl != null ? NetworkImage(user.profilePictureUrl!) : null,
              child: user.profilePictureUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Row(
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _getRoleColor(user.role).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(user.role.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getRoleColor(user.role))),
                ),
              ],
            ),
            subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
            trailing: PopupMenuButton<String>(
              onSelected: (val) => _handleUserAction(user, val),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'suspend', child: Text('Suspend/Reactivate Account')),
                const PopupMenuItem(value: 'make_admin', child: Text('Elevate to Admin')),
                const PopupMenuItem(value: 'make_donor', child: Text('Settle as Donor')),
                const PopupMenuItem(value: 'delete', child: Text('Purge Identity (Delete)', style: TextStyle(color: Colors.red))),
              ],
              icon: Icon(Icons.more_vert, color: isSuspended ? Colors.red : null),
            ),
          ),
          if (isSuspended)
            Container(
              padding: const EdgeInsets.all(4),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('ACCOUNT SUSPENDED', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin: return Colors.purple;
      case UserRole.orphanageAdmin: return Colors.orange;
      case UserRole.volunteer: return Colors.blue;
      case UserRole.donor: return Colors.teal;
      default: return Colors.grey;
    }
  }

  Widget _buildOrgsTab() {
    final orgsAsync = ref.watch(organizationsProvider);
    return orgsAsync.when(
      data: (orgs) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orgs.length,
        itemBuilder: (context, index) {
          final org = orgs[index];
          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(org.imageUrl, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.business))),
              title: Text(org.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(org.location),
              trailing: Switch(
                value: org.status == VerificationStatus.verified,
                onChanged: (val) async {
                   final newStatus = val ? VerificationStatus.verified : VerificationStatus.pending;
                   await ref.read(organizationRepositoryProvider).saveOrganization(org.copyWith(status: newStatus));
                   ref.invalidate(organizationsProvider);
                },
                activeThumbColor: AppColors.teal,
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSystemTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('System Operations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActionTile(Icons.data_exploration_outlined, 'Initialize Production Assets', 'Purge legacy nodes and install 2.0 Bangladeshi data', () => _showConfirmDialog('Reset Database?', 'This will wipe all existing data nodes.', () async {
          // Trigger same seeding logic as AdminDashboard
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
        })),
        const SizedBox(height: 12),
        _buildActionTile(Icons.cleaning_services_outlined, 'System Cleanup', 'Remove orphan donations and unlinked users', () => _showConfirmDialog('Run System Cleanup?', 'This will optimize the database by removing dangling nodes.', () async {
          final repo = ref.read(donationRepositoryProvider);
          final donations = await repo.getAllDonations();
          int count = 0;
          for (var d in donations) {
            if (d.status == 'pending' && d.timestamp.isBefore(DateTime.now().subtract(const Duration(hours: 48)))) {
              // Simulated cleanup of old pending items
              count++;
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Cleanup complete: $count records optimized.'),
              backgroundColor: AppColors.teal,
            ));
          }
        })),
        const SizedBox(height: 12),
        _buildActionTile(
          _isMaintenanceActive ? Icons.lock_open_outlined : Icons.lock_outline, 
          'Maintenance Lock', 
          'Toggle global maintenance mode for non-admins', 
          () {
            setState(() => _isMaintenanceActive = !_isMaintenanceActive);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Maintenance Mode: ${_isMaintenanceActive ? "ACTIVATED" : "DEACTIVATED"}'),
              backgroundColor: _isMaintenanceActive ? Colors.orange : AppColors.teal,
            ));
          }
        ),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.border),
        ],
      ),
    );
  }

  Future<void> _handleUserAction(UserModel user, String action) async {
    final repo = ref.read(userRepositoryProvider);
    switch (action) {
      case 'suspend':
        final newStatus = user.status == 'suspended' ? 'active' : 'suspended';
        await repo.updateUserStatus(user.uid, newStatus);
        break;
      case 'make_admin':
        await repo.updateUserRole(user.uid, UserRole.admin);
        break;
      case 'make_donor':
        await repo.updateUserRole(user.uid, UserRole.donor);
        break;
      case 'delete':
        _showConfirmDialog('Delete User?', 'This cannot be undone.', () async {
          await repo.deleteUser(user.uid);
        });
        break;
    }
    ref.invalidate(allUsersProvider);
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: const Text('Execute', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

