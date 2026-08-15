import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/models/organization_model.dart';
import '../../organizations/data/organization_repository.dart';

class ManageOrganizationsPage extends ConsumerStatefulWidget {
  const ManageOrganizationsPage({super.key});

  @override
  ConsumerState<ManageOrganizationsPage> createState() => _ManageOrganizationsPageState();
}

class _ManageOrganizationsPageState extends ConsumerState<ManageOrganizationsPage> {
  VerificationStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Organizations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(VerificationStatus.pending, 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip(VerificationStatus.verified, 'Verified'),
                const SizedBox(width: 8),
                _buildFilterChip(VerificationStatus.rejected, 'Rejected'),
              ],
            ),
          ),
        ),
      ),
      body: organizationsAsync.when(
        data: (organizations) {
          final filteredOrgs = _filterStatus == null 
              ? organizations 
              : organizations.where((o) => o.status == _filterStatus).toList();

          if (filteredOrgs.isEmpty) {
            return Center(child: Text('No ${_filterStatus?.name ?? ""} organizations found.'));
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: filteredOrgs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final org = filteredOrgs[index];
              return AppCard(
                child: Column(
                  children: [
                    Row(
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
                              Row(
                                children: [
                                  Text(
                                    org.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(org.status),
                                ],
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
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _handleDelete(org),
                        ),
                      ],
                    ),
                    if (org.status == VerificationStatus.pending) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _handleVerification(org, VerificationStatus.rejected),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _handleVerification(org, VerificationStatus.verified),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Verify'),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildFilterChip(VerificationStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _filterStatus = status);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatusBadge(VerificationStatus status) {
    Color color = Colors.grey;
    if (status == VerificationStatus.verified) color = Colors.green;
    if (status == VerificationStatus.rejected) color = Colors.red;
    if (status == VerificationStatus.pending) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleVerification(Organization org, VerificationStatus newStatus) async {
    try {
      final updatedOrg = org.copyWith(
        status: newStatus,
        approvedAt: newStatus == VerificationStatus.verified ? DateTime.now() : null,
      );
      await ref.read(organizationRepositoryProvider).saveOrganization(updatedOrg);
      ref.invalidate(organizationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Organization ${newStatus.name} successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(Organization org) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organization'),
        content: Text('Are you sure you want to delete "${org.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(organizationActionsProvider).deleteOrganization(org.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Organization deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

