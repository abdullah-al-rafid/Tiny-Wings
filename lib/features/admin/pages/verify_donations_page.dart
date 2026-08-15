import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/models/donation_model.dart';
import '../providers/admin_providers.dart';
import '../../donations/data/donation_repository.dart';
import '../../needs/data/need_repository.dart';
import '../../notifications/data/notification_repository.dart';
import '../../../core/models/notification_model.dart';

class VerifyDonationsPage extends ConsumerStatefulWidget {
  const VerifyDonationsPage({super.key});

  @override
  ConsumerState<VerifyDonationsPage> createState() => _VerifyDonationsPageState();
}

class _VerifyDonationsPageState extends ConsumerState<VerifyDonationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateDonation(String id, Map<String, dynamic> updates) async {
    try {
      await ref.read(donationRepositoryProvider).updateDonation(id, updates);
      ref.invalidate(allDonationsProvider);
      ref.invalidate(adminStatsProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _showStatusDialog(Donation donation) {
    if (donation.id == null) return;
    
    final valueController = TextEditingController(text: donation.approvedValue?.toStringAsFixed(0) ?? donation.estimatedValue?.toStringAsFixed(0) ?? '');
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
              Text(
                donation.status == 'pending' ? 'Verify Donation' : 'Update Logistics',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Item', donation.itemName ?? 'Unknown'),
              _buildDetailRow('Current Status', donation.status.toUpperCase()),
              const Divider(height: 32),
              if (donation.status == 'pending') ...[
                const Text('Approve with Value ৳', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(prefixText: '৳ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Admin Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(hintText: 'Notes for user...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 32),
              if (donation.status == 'pending')
                 AppButton(
                   text: 'Approve & Verify',
                   onPressed: () async {
                     final val = double.tryParse(valueController.text);
                     if (val == null) return;
                     if (donation.needId != null && donation.quantity != null) {
                       await ref.read(needRepositoryProvider).updateNeedFulfillment(donation.needId!, donation.quantity!);
                     }
                     await _updateDonation(donation.id!, {'status': 'verified', 'approvedValue': val, 'adminNote': notesController.text});
                     
                     // Notify donor
                     try {
                       await ref.read(notificationRepositoryProvider).sendNotification(AppNotification(
                         id: DateTime.now().millisecondsSinceEpoch.toString(),
                         userId: donation.donorId,
                         title: 'Donation Verified! 🎊',
                         message: 'Your donation of ${donation.itemName} has been verified with a value of ৳${val.toStringAsFixed(0)}.',
                         type: NotificationType.donation,
                         timestamp: DateTime.now(),
                         relatedId: donation.id,
                       ));
                     } catch (e) {
                        print('Notification failed: $e');
                     }

                     if (context.mounted) Navigator.pop(context);
                   },
                 )
              else if (donation.status == 'verified')
                 AppButton(
                   text: 'Mark as In-Transit',
                   onPressed: () {
                     _updateDonation(donation.id!, {'status': 'shipped', 'adminNote': notesController.text});
                     Navigator.pop(context);
                   },
                 )
              else if (donation.status == 'shipped')
                 AppButton(
                   text: 'Mark as Received',
                   onPressed: () {
                     _updateDonation(donation.id!, {'status': 'received', 'adminNote': notesController.text});
                     Navigator.pop(context);
                   },
                 ),
              const SizedBox(height: 12),
              if (donation.status == 'pending')
                TextButton(
                  onPressed: () {
                    _updateDonation(donation.id!, {'status': 'rejected', 'adminNote': notesController.text});
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Logistics'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'New Pending'),
            Tab(text: 'Active Tracking'),
          ],
        ),
      ),
      body: statsAsync.when(
        data: (stats) {
          final pending = stats.allDonations.where((d) => d.status == 'pending').toList();
          final active = stats.allDonations.where((d) => ['verified', 'shipped'].contains(d.status)).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(pending, 'No pending reviews'),
              _buildList(active, 'No active deliveries'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildList(List<Donation> donations, String emptyMsg) {
    if (donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(emptyMsg, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: donations.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (c, i) {
        final d = donations[i];
        return AppCard(
          onTap: () => _showStatusDialog(d),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor(d.status).withValues(alpha: 0.1),
                child: Icon(_getStatusIcon(d.status), color: _getStatusColor(d.status), size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.itemName ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(d.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(d.status))),
                  ],
                ),
              ),
              Text('৳${d.approvedValue?.toStringAsFixed(0) ?? d.estimatedValue?.toStringAsFixed(0) ?? "0"}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.amber;
      case 'verified': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'received': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'verified': return Icons.check_circle_outline;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'received': return Icons.home_work_outlined;
      default: return Icons.help_outline;
    }
  }
}

