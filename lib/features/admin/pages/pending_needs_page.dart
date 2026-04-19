import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../needs/providers/need_providers.dart';
import '../../needs/data/need_repository.dart';

class PendingNeedsPage extends ConsumerWidget {
  const PendingNeedsPage({super.key});

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, String status) async {
    try {
      final repository = ref.read(needRepositoryProvider);
      await repository.updateNeedStatus(id, status);
      ref.invalidate(pendingNeedsProvider);
      ref.invalidate(approvedNeedsProvider);
      ref.invalidate(needsByOrgProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Need $status!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingNeedsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Needs')),
      backgroundColor: AppColors.background,
      body: pendingAsync.when(
        data: (needs) {
          if (needs.isEmpty) {
            return const Center(child: Text('No pending needs to verify.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(pendingNeedsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: needs.length,
              itemBuilder: (context, index) {
                final need = needs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(need.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Org: ${need.organizationName ?? 'Unknown'}', style: const TextStyle(color: AppColors.textSecondary)),
                        Text('Category: ${need.category}'),
                        Text('Priority: ${need.priority}', style: TextStyle(color: need.priority == 'Urgent' ? AppColors.coral : AppColors.textPrimary)),
                        Text('Qty: ${need.quantityOrAmount}'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Reject',
                                style: AppButtonStyle.secondary,
                                onPressed: () => _updateStatus(context, ref, need.id, 'rejected'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppButton(
                                text: 'Approve',
                                style: AppButtonStyle.primary,
                                onPressed: () => _updateStatus(context, ref, need.id, 'approved'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
