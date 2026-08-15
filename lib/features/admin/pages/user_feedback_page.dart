import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../settings/providers/support_providers.dart';
import '../../settings/data/support_repository.dart';
import '../../../core/models/support_ticket_model.dart';

class UserFeedbackPage extends ConsumerStatefulWidget {
  const UserFeedbackPage({super.key});

  @override
  ConsumerState<UserFeedbackPage> createState() => _UserFeedbackPageState();
}

class _UserFeedbackPageState extends ConsumerState<UserFeedbackPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Question', 'Suggestion', 'Complaint'];
  final TextEditingController _replyController = TextEditingController();

  Future<void> _submitReply(SupportTicket ticket) async {
    if (_replyController.text.trim().isEmpty) return;

    final updatedTicket = ticket.copyWith(
      adminReply: _replyController.text.trim(),
      repliedAt: DateTime.now().millisecondsSinceEpoch,
      status: 'resolved',
    );

    try {
      await ref.read(supportRepositoryProvider).updateTicket(updatedTicket);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply sent successfully!'), backgroundColor: AppColors.teal),
        );
        ref.invalidate(allAdminTicketsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reply: $e'), backgroundColor: AppColors.coral),
        );
      }
    }
  }

  void _showReplyDialog(SupportTicket ticket) {
    _replyController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${ticket.userName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Original Topic: ${ticket.subject}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _replyController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your response here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _submitReply(ticket),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Send Reply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(allAdminTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedback & Suggestions'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ticketsAsync.when(
              data: (tickets) {
                final filteredTickets = selectedFilter == 'All' 
                    ? tickets 
                    : tickets.where((t) => t.category == selectedFilter).toList();

                if (filteredTickets.isEmpty) {
                  return const Center(child: Text('No messages found for this category.'));
                }

                // Mark as read by admin
                for (final ticket in filteredTickets) {
                  if (!ticket.isReadByAdmin) {
                    ref.read(supportRepositoryProvider).markAsReadByAdmin(ticket);
                  }
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTickets.length,
                  itemBuilder: (context, index) => _buildFeedbackCard(filteredTickets[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filter),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackCard(SupportTicket ticket) {
    bool isResolved = ticket.status == 'resolved';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (ticket.category == 'Complaint' ? AppColors.coral : AppColors.teal).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.category.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ticket.category == 'Complaint' ? AppColors.coral : AppColors.teal),
                ),
              ),
              Text(_formatDate(ticket.timestamp), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(ticket.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(ticket.userEmail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Divider(height: 24),
          Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(ticket.message),
          const SizedBox(height: 16),
          
          if (isResolved)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.teal, size: 16),
                      SizedBox(width: 8),
                      Text('Admin Response sent', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(ticket.adminReply!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _showReplyDialog(ticket),
              icon: const Icon(Icons.reply, size: 18),
              label: const Text('Reply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}

