import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../organizations/data/organization_repository.dart';
import '../../../core/models/organization_model.dart';
import '../../admin/providers/admin_providers.dart';

class ManageApplicationsPage extends ConsumerStatefulWidget {
  const ManageApplicationsPage({super.key});

  @override
  ConsumerState<ManageApplicationsPage> createState() => _ManageApplicationsPageState();
}

class _ManageApplicationsPageState extends ConsumerState<ManageApplicationsPage> {
  bool _isProcessing = false;

  Future<void> _handleAction(Organization org, VerificationStatus newStatus) async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrg = org.copyWith(
        status: newStatus,
        approvedAt: newStatus == VerificationStatus.verified ? DateTime.now() : null,
      );
      
      await ref.read(organizationRepositoryProvider).saveOrganization(updatedOrg);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Organization ${newStatus == VerificationStatus.verified ? "Approved" : "Rejected"}'),
            backgroundColor: newStatus == VerificationStatus.verified ? AppColors.teal : AppColors.coral,
          ),
        );
        ref.invalidate(organizationsProvider);
        ref.invalidate(adminStatsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Applications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: organizationsAsync.when(
        data: (orgs) {
          final pendingOrgs = orgs.where((o) => o.status == VerificationStatus.pending).toList();

          if (pendingOrgs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No pending applications', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pendingOrgs.length,
            itemBuilder: (context, index) {
              final org = pendingOrgs[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(org.imageUrl, width: 80, height: 80, fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey.shade100, child: const Icon(Icons.business))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(org.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(org.location, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Email: ${org.email}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(org.description, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isProcessing ? null : () => _handleAction(org, VerificationStatus.rejected),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.coral,
                              side: const BorderSide(color: AppColors.coral),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : () => _handleAction(org, VerificationStatus.verified),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

