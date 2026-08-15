import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/volunteer_providers.dart';
import '../../../core/models/opportunity_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/user_providers.dart';
import '../../../core/models/user_model.dart';
import '../data/volunteer_repository.dart';
import '../../../core/localization/app_localization.dart';
import 'dart:ui';

class OpportunityBoardPage extends ConsumerStatefulWidget {
  const OpportunityBoardPage({super.key});

  @override
  ConsumerState<OpportunityBoardPage> createState() => _OpportunityBoardPageState();
}

class _OpportunityBoardPageState extends ConsumerState<OpportunityBoardPage> {
  OpportunityCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final opportunitiesAsync = ref.watch(lifeOpportunitiesProvider);
    final user = ref.watch(userProfileProvider).value;
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t['opp_board']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (user?.role == UserRole.admin || user?.role == UserRole.opportunityPoster || user?.role == UserRole.orphanageAdmin)
            IconButton(
              icon: const Icon(Icons.post_add, color: Color(0xFF1E3A8A)),
              onPressed: () => context.push('/opportunity-board/add'),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background
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
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _buildCategoryChip(null, t['all']!),
                      ...OpportunityCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildCategoryChip(cat, t[cat.name] ?? cat.name),
                      )),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                // List of Opportunities
                Expanded(
                  child: opportunitiesAsync.when(
                    data: (opportunities) {
                      final filtered = _selectedCategory == null 
                          ? opportunities 
                          : opportunities.where((o) => o.category == _selectedCategory).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            t['no_opportunities'] ?? 'No opportunities found',
                            style: const TextStyle(color: Color(0xFF1E3A8A)),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final opp = filtered[index];
                          return _OpportunityCard(opp: opp);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(OpportunityCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = category);
      },
      selectedColor: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      side: BorderSide(color: isSelected ? const Color(0xFF1E3A8A) : Colors.white.withValues(alpha: 0.5)),
      labelStyle: TextStyle(
        color: const Color(0xFF1E3A8A),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _OpportunityCard extends ConsumerWidget {
  final Opportunity opp;

  const _OpportunityCard({required this.opp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationProvider);
    final user = ref.watch(userProfileProvider).value;
    final isAdmin = user?.role == UserRole.admin;
    final isOwner = user?.uid == opp.postedBy || user?.role == UserRole.orphanageAdmin;
    final canManage = isAdmin || isOwner;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryBadge(context, opp.category, t),
                Row(
                  children: [
                    if (canManage) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E3A8A), size: 20),
                        onPressed: () => context.push('/opportunity-board/edit', extra: opp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteOpportunity(context, ref),
                      ),
                      if (isAdmin && opp.status == OpportunityStatus.pending)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                          onPressed: () => _updateStatus(context, ref, OpportunityStatus.approved),
                        ),
                    ],
                    if (opp.deadline != null)
                      Text(
                        '${t['deadline']}: ${opp.deadline!.day}/${opp.deadline!.month}/${opp.deadline!.year}',
                        style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              opp.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              opp.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
            ),
            const SizedBox(height: 16),
            _IconLabel(icon: Icons.location_on_outlined, label: opp.location),
            const SizedBox(height: 8),
            _IconLabel(icon: Icons.info_outline, label: '${t['eligibility']}: ${opp.eligibility}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _showContactDialog(context, opp, t),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(t['view_details']!, style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),);
  }

  Widget _buildCategoryBadge(BuildContext context, OpportunityCategory category, Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        (t[category.name] ?? category.name).toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  void _showContactDialog(BuildContext context, Opportunity opp, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(opp.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['apply_method']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            Text(opp.contactMethod, style: const TextStyle(color: Color(0xFF4B5563))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _deleteOpportunity(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Opportunity'),
        content: Text('Are you sure you want to delete "${opp.title}"?'),
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
      await ref.read(volunteerActionsProvider).deleteLifeOpportunity(opp.id);
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, OpportunityStatus status) async {
    await ref.read(volunteerActionsProvider).updateLifeOpportunityStatus(opp.id, status);
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}

