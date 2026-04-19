import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/user_providers.dart';
import '../data/support_repository.dart';
import '../providers/support_providers.dart';
import '../../../models/support_ticket_model.dart';
import '../../../models/user_model.dart';

class HelpSupportPage extends ConsumerStatefulWidget {
  const HelpSupportPage({super.key});

  @override
  ConsumerState<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends ConsumerState<HelpSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Question';
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I donate?',
      'a': 'Navigate to the "Donate" tab, select an organization or need, and follow the simple steps to contribute money or items.'
    },
    {
      'q': 'What is a Monthly Sponsorship?',
      'a': 'It\'s a recurring contribution that provides stable, long-term support for a child or an entire organization. You can manage these in My Sponsorships.'
    },
    {
      'q': 'Are my transactions secure?',
      'a': 'Yes, we use encrypted payment gateways to ensure your data and contributions are 100% safe and transparent.'
    },
    {
      'q': 'How are physical items verified?',
      'a': 'Once you submit a physical donation, our admins review the photos and description. Once verified, the value is added to your impact!'
    },
    {
      'q': 'Can I remain anonymous?',
      'a': 'Yes! Go to Privacy Settings and enable "Anonymous Mode" to hide your real name from the public leaderboard.'
    },
  ];

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final ticket = SupportTicket(
      id: '', // Will be set by Firebase post
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      category: _selectedCategory,
      subject: _subjectController.text,
      message: _messageController.text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await ref.read(supportRepositoryProvider).saveTicket(ticket);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Message sent! Our team will reply soon.'),
              ],
            ),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _subjectController.clear();
        _messageController.clear();
        ref.invalidate(userTicketsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppColors.coral),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }



  Future<void> _launchEmail() async {
    final String email = 'admin@tinywings.com';
    final String subject = '[$_selectedCategory] ${_subjectController.text}';
    final String body = _messageController.text;
    
    final Uri emailUrl = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
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

          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar
                _buildAppBar(),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    children: [
                      _buildFAQSection(),
                      const SizedBox(height: 32),
                      _buildContactForm(),
                      const SizedBox(height: 32),
                      _buildHistorySection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.4))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: const Color(0xFF1E3A8A),
                onPressed: () => context.pop(),
              ),
              const Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 16),
        ..._faqs.map((faq) => _buildFAQTile(faq['q']!, faq['a']!)),
      ],
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyle(fontSize: 13, color: const Color(0xFF1E3A8A).withValues(alpha: 0.7), height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Send us a message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Have a suggestion or complaint? Let us know!',
              style: TextStyle(fontSize: 12, color: const Color(0xFF1E3A8A).withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),
            
            // Category Dropdown
            _buildDropdown(),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _subjectController,
              label: 'Subject',
              hint: 'What is this about?',
              validator: (v) => v!.isEmpty ? 'Please enter a subject' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _messageController,
              label: 'Message',
              hint: 'Tell us more...',
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Please enter your message' : null,
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: ['Question', 'Suggestion', 'Complaint'].map((c) {
                return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.35), fontSize: 13),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    final ticketsAsync = ref.watch(userTicketsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Messages & Responses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 16),
        ticketsAsync.when(
          data: (tickets) {
            if (tickets.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No previous messages found.', style: TextStyle(color: const Color(0xFF1E3A8A).withValues(alpha: 0.5))),
                ),
              );
            }
            // Mark all tickets as read when viewing history
            for (final ticket in tickets) {
              if (!ticket.isReadByUser) {
                ref.read(supportRepositoryProvider).markAsReadByUser(ticket);
              }
            }
            
            return Column(
              children: tickets.map((t) => _buildTicketCard(t)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading history: $e'),
        ),
      ],
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    bool hasReply = ticket.adminReply != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasReply ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6)),
      ),
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
              Text(
                _formatDate(ticket.timestamp),
                style: TextStyle(fontSize: 11, color: const Color(0xFF1E3A8A).withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A8A))),
          const SizedBox(height: 4),
          Text(ticket.message, style: TextStyle(fontSize: 13, color: const Color(0xFF1E3A8A).withValues(alpha: 0.7))),
          
          if (hasReply) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFF3B82F6), thickness: 0.2),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.reply_rounded, color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin Response', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3B82F6))),
                      const SizedBox(height: 4),
                      Text(ticket.adminReply!, style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A))),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text('Awaiting Response', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}
