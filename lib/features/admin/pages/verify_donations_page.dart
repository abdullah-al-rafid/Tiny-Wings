import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/donation_model.dart';
import '../providers/admin_providers.dart';
import '../../donations/data/donation_repository.dart';
import '../../needs/data/need_repository.dart';

class VerifyDonationsPage extends ConsumerStatefulWidget {
  const VerifyDonationsPage({super.key});

  @override
  ConsumerState<VerifyDonationsPage> createState() => _VerifyDonationsPageState();
}

class _VerifyDonationsPageState extends ConsumerState<VerifyDonationsPage> {
  Future<void> _updateDonation(String id, Map<String, dynamic> updates) async {
    try {
      await ref.read(donationRepositoryProvider).updateDonation(id, updates);
      
      // Refresh admin stats to update lists everywhere
      ref.invalidate(allDonationsProvider);
      ref.invalidate(adminStatsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _showVerificationDialog(Donation donation) {
    if (donation.id == null) return;
    
    final valueController = TextEditingController(
        text: donation.estimatedValue?.toStringAsFixed(0) ?? '');
    final notesController = TextEditingController(text: donation.adminNote ?? '');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verify Donation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              _buildDetailRow('Category', donation.itemCategory ?? 'Unknown'),
              _buildDetailRow('Item', donation.itemName ?? 'Unknown Item'),
              _buildDetailRow('Quantity', '${donation.quantity?.toStringAsFixed(1)} ${donation.unit ?? ""}'),
              _buildDetailRow('Est Value', '৳${donation.estimatedValue?.toStringAsFixed(0) ?? "0"}'),
              
              const SizedBox(height: 24),
              const Text('Final Approved Value ৳', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter final value',
                  prefixText: '৳ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              
              const SizedBox(height: 16),
              const Text('Admin Note (Visible to User)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Optional notes for user...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              
              const SizedBox(height: 32),
              AppButton(
                text: 'Approve & Verify',
                onPressed: () async {
                  final finalValue = double.tryParse(valueController.text);
                  if (finalValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please enter a valid monetary value'))
                    );
                    return;
                  }
                  
                  if (donation.needId != null && donation.quantity != null) {
                    try {
                      await ref.read(needRepositoryProvider).updateNeedFulfillment(donation.needId!, donation.quantity!);
                    } catch (e) {
                      debugPrint('Failed to update need math: $e');
                    }
                  }
                  
                  await _updateDonation(donation.id!, {
                    'status': 'verified',
                    'approvedValue': finalValue,
                    if (notesController.text.isNotEmpty) 'adminNote': notesController.text,
                  });
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _updateDonation(donation.id!, {
                    'status': 'rejected',
                    if (notesController.text.isNotEmpty) 'adminNote': notesController.text,
                  });
                  Navigator.pop(context);
                },
                child: const Text('Reject Donation', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Applications'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: statsAsync.when(
        data: (stats) {
          final pendingDonations = stats.allDonations
              .where((d) => d.status == 'pending')
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (pendingDonations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.border),
                  const SizedBox(height: 24),
                  const Text(
                    'All Caught Up!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('No pending item donations to review.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: pendingDonations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final donation = pendingDonations[index];
              final date = DateFormat('MMM dd, yyyy').format(donation.timestamp);
              
              return AppCard(
                onTap: () => _showVerificationDialog(donation),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pending_actions, color: Color(0xFFD97706)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donation.itemName ?? donation.itemCategory ?? 'Unknown Item',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Org: ${donation.organizationName}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            date,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${donation.quantity?.toStringAsFixed(1)} ${donation.unit ?? ""}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                        ),
                        if (donation.estimatedValue != null)
                          Text(
                            'Est: ৳${donation.estimatedValue?.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
