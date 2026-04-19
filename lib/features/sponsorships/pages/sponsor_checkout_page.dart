import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/subscription_model.dart';
import '../../../core/auth/auth_repository.dart';
import '../data/sponsorship_repository.dart';
import '../providers/sponsorship_providers.dart';

class SponsorCheckoutPage extends ConsumerStatefulWidget {
  final String targetType; // 'org' or 'child'
  final String targetId;
  final String targetName;
  final String orgId;
  final double amount; // 1000/2500/5000 for org. Unlocked for child
  final Subscription? subscriptionToRenew;

  const SponsorCheckoutPage({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.orgId,
    required this.amount,
    this.subscriptionToRenew,
  });

  @override
  ConsumerState<SponsorCheckoutPage> createState() => _SponsorCheckoutPageState();
}

class _SponsorCheckoutPageState extends ConsumerState<SponsorCheckoutPage> {
  final _phoneController = TextEditingController();
  final _trxIdController = TextEditingController();
  bool _isLoading = false;
  String _selectedPayment = 'bKash';

  @override
  void dispose() {
    _phoneController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  Future<void> _submitPledge() async {
    final user = ref.read(authModelProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in')));
      return;
    }
    
    if (_phoneController.text.isEmpty || _trxIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter payment details')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.subscriptionToRenew != null) {
        final sub = widget.subscriptionToRenew!;
        await ref.read(sponsorshipRepositoryProvider).updateSubscriptionStatus(sub.id!, 'active');
        await ref.read(sponsorshipRepositoryProvider).logPayment(sub);
      } else {
        final sub = Subscription(
          donorId: user.uid,
          donorName: user.email.isNotEmpty ? user.email.split('@').first : 'Anonymous Sponsor',
          targetType: widget.targetType,
          targetId: widget.targetId,
          targetName: widget.targetName,
          orgId: widget.orgId,
          amount: widget.amount,
          status: 'active', // Auto-activate for testing Phase
          startDate: DateTime.now(),
          lastPaymentDate: DateTime.now(),
        );

        await ref.read(sponsorshipRepositoryProvider).saveSubscription(sub);
      }

      ref.invalidate(userSubscriptionsProvider);
      ref.invalidate(orgSponsorsProvider);
      ref.invalidate(activeUserSubscriptionsProvider);
      ref.invalidate(orgSupportersProvider(widget.orgId));

      if (mounted) {
        context.go('/home'); // Or donation confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.subscriptionToRenew != null ? 'Sponsorship Renewed!' : 'Sponsorship Activated!'))
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                   const Icon(Icons.stars, color: AppColors.primary, size: 48),
                   const SizedBox(height: 16),
                   Text('Sponsoring ${widget.targetName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('Monthly Plege: ৳${widget.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPaymentMethod('bKash'),
                const SizedBox(width: 12),
                _buildPaymentMethod('Nagad'),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: '$_selectedPayment Number'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trxIdController,
              decoration: const InputDecoration(labelText: 'Transaction ID (TrxID)'),
            ),
            const SizedBox(height: 48),
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : AppButton(
                  text: 'Confirm Payment',
    onPressed: _submitPledge,
                )
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethod(String method) {
    bool isSelected = _selectedPayment == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPayment = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(method, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
