import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../sponsorships/providers/sponsorship_providers.dart';
import '../providers/organization_providers.dart';

class OrganizationSupportersPage extends ConsumerWidget {
  final String orgId;

  const OrganizationSupportersPage({super.key, required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportersAsync = ref.watch(orgSupportersProvider(orgId));
    final orgAsync = ref.watch(organizationDetailsProvider(orgId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: orgAsync.when(
            data: (org) => Text('Supporters of ${org?.name ?? "..."}'),
            loading: () => const Text('Loading...'),
            error: (e, _) => const Text('Supporters'),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Monthly Sponsors'),
              Tab(text: 'Top Donors'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),
        body: supportersAsync.when(
          data: (supporters) {
            if (supporters.isEmpty) {
              return const Center(child: Text('No supporters found yet. Be the first!'));
            }

            final sponsors = supporters.where((s) => s.isMonthly).toList();
            final donors = supporters.where((s) => !s.isMonthly).toList();

            return TabBarView(
              children: [
                _buildSupporterList(sponsors, 'No active monthly sponsors yet.'),
                _buildSupporterList(donors, 'No donations yet.'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildSupporterList(List<dynamic> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final supporter = list[index];
        final amount = supporter.totalAmount;
        
        Color tierColor;
        Color bgColor;
        IconData tierIcon;
        if (amount >= 5000) {
          tierColor = Colors.amber.shade900;
          bgColor = Colors.amber.shade50;
          tierIcon = Icons.workspace_premium;
        } else if (amount >= 2500) {
          tierColor = Colors.blueGrey.shade600;
          bgColor = Colors.blueGrey.shade50;
          tierIcon = Icons.stars;
        } else if (supporter.isMonthly) {
          tierColor = Colors.orange.shade800;
          bgColor = Colors.orange.shade50;
          tierIcon = Icons.emoji_events;
        } else {
          tierColor = AppColors.primary;
          bgColor = Colors.white;
          tierIcon = Icons.volunteer_activism;
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            color: bgColor,
            border: amount >= 2500 ? Border.all(color: tierColor.withValues(alpha: 0.5), width: 1) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: tierColor.withValues(alpha: 0.1),
                child: Icon(tierIcon, color: tierColor, size: 20),
              ),
              title: Text(supporter.donorName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(supporter.rankTitle),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('৳${supporter.totalAmount.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, color: tierColor, fontSize: 16)),
                  Text(supporter.isMonthly ? 'monthly' : 'total', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
