import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/sponsorship_providers.dart';
import '../data/sponsorship_repository.dart';
import '../../../core/models/subscription_model.dart';

class MySponsorshipsPage extends ConsumerStatefulWidget {
  const MySponsorshipsPage({super.key});

  @override
  ConsumerState<MySponsorshipsPage> createState() => _MySponsorshipsPageState();
}

class _MySponsorshipsPageState extends ConsumerState<MySponsorshipsPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSubsAsync = ref.watch(userSubscriptionsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient
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

          // Decorative blobs
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF93C5FD).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC4B5FD).withValues(alpha: 0.3),
              ),
            ),
          ),

          // Blur
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox(),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Frosted AppBar
                ClipRRect(
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
                            'My Sponsorships',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Body
                Expanded(
                  child: RepaintBoundary(
                    child: activeSubsAsync.when(
                      data: (subs) {
                        if (subs.isEmpty) return _buildEmptyState();
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                          itemCount: subs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) =>
                              _SubscriptionCard(subscription: subs[index]),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.handshake_rounded, size: 64, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 28),
          const Text(
            'No sponsorships yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sponsor a child or an organization to make a lasting impact.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Subscription Card ──────────────────────────────────────────────────────

class _SubscriptionCard extends ConsumerStatefulWidget {
  final Subscription subscription;
  const _SubscriptionCard({required this.subscription});

  @override
  ConsumerState<_SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<_SubscriptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final sub = widget.subscription;
    final isActive = sub.status == 'active';
    final isDue = isActive &&
        DateTime.now().difference(sub.lastPaymentDate).inMinutes >= 2;

    // Color theme based on status
    final Color accentColor = isActive
        ? (isDue ? const Color(0xFFF59E0B) : const Color(0xFF059669))
        : const Color(0xFF9CA3AF);
    final Color accentBg = isActive
        ? (isDue
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFECFDF5))
        : const Color(0xFFF3F4F6);

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.012 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? accentColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? accentColor.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon badge
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: accentBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.handshake_rounded, size: 22, color: accentColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.targetName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: _isHovered
                                        ? const Color(0xFF1E3A8A)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Monthly ৳${sub.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          _StatusChip(
                            label: isDue ? 'Due Now' : (isActive ? 'Active' : 'Cancelled'),
                            color: accentColor,
                            bg: accentBg,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Stats row
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                          child: Row(
                            children: [
                              _StatItem(
                                icon: Icons.payments_rounded,
                                label: 'Total Paid',
                                value: '৳${sub.totalAmountPaid.toStringAsFixed(0)}',
                                color: const Color(0xFF3B82F6),
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.grey.withValues(alpha: 0.2),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              _StatItem(
                                icon: Icons.receipt_long_rounded,
                                label: 'Payments',
                                value: '${sub.totalPayments}',
                                color: const Color(0xFF8B5CF6),
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.grey.withValues(alpha: 0.2),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              _StatItem(
                                icon: Icons.calendar_month_rounded,
                                label: 'Last Paid',
                                value: _formatDate(sub.lastPaymentDate),
                                color: const Color(0xFF059669),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(child: _PaymentButton(
                            isDue: isDue,
                            isActive: isActive,
                            onTap: (isDue || !isActive)
                                ? () => context.push('/sponsorship-checkout', extra: {
                                      'targetType': sub.targetType,
                                      'targetId': sub.targetId,
                                      'targetName': sub.targetName,
                                      'orgId': sub.orgId,
                                      'amount': sub.amount,
                                      'subscriptionToRenew': sub,
                                    })
                                : null,
                          )),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                text: 'Change Plan',
                                onPressed: () => _showChangePlanDialog(context, ref),
                                style: AppButtonStyle.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (isActive) ...[
                        const SizedBox(height: 4),
                        _HoverableCancelButton(
                          onTap: () => _showCancelDialog(context, ref),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  void _showChangePlanDialog(BuildContext context, WidgetRef ref) {
    final sub = widget.subscription;
    final isOrg = sub.targetType == 'org';
    double selectedAmount = sub.amount;
    final controller = TextEditingController(text: sub.amount.toStringAsFixed(0));

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change Sponsorship Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isOrg ? 'Select a new tier:' : 'Enter new monthly amount (৳):',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    if (isOrg)
                      DropdownButtonFormField<double>(
                        value: [1000.0, 2500.0, 5000.0].contains(selectedAmount)
                            ? selectedAmount
                            : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1000.0, child: Text('🥉 Bronze — ৳1,000')),
                          DropdownMenuItem(value: 2500.0, child: Text('🥈 Silver — ৳2,500')),
                          DropdownMenuItem(value: 5000.0, child: Text('🥇 Gold — ৳5,000')),
                        ],
                        hint: const Text('Select Tier'),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedAmount = val);
                        },
                      )
                    else
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: '৳ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) selectedAmount = parsed;
                        },
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedAmount > 0) {
                                await ref
                                    .read(sponsorshipRepositoryProvider)
                                    .updateSubscriptionAmount(sub.id!, selectedAmount);
                                ref.invalidate(userSubscriptionsProvider);
                                ref.invalidate(orgSupportersProvider(sub.orgId));
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Update',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    final sub = widget.subscription;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFEE2E2),
                    ),
                    child: const Icon(Icons.cancel_rounded, size: 36, color: Color(0xFFDC2626)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cancel Sponsorship?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you sure you want to cancel this monthly sponsorship? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Keep It'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(sponsorshipRepositoryProvider)
                                .updateSubscriptionStatus(sub.id!, 'cancelled');
                            ref.invalidate(userSubscriptionsProvider);
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel Now',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ─────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _StatusChip({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _HoverableCancelButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverableCancelButton({required this.onTap});

  @override
  State<_HoverableCancelButton> createState() => _HoverableCancelButtonState();
}

class _HoverableCancelButtonState extends State<_HoverableCancelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFFEE2E2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Cancel Sponsorship',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isHovered ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Semantic Payment Button ─────────────────────────────────────────────────

class _PaymentButton extends StatefulWidget {
  final bool isDue;
  final bool isActive;
  final VoidCallback? onTap;

  const _PaymentButton({
    required this.isDue,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<_PaymentButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // ── Determine variant ──────────────────────────────────────────────────
    // "Pay Now"  → vivid green (like Stripe / PayPal)
    // "Paid"     → soft muted green-grey (confirmed/inactive)
    // "Renew"    → warm amber (action needed, not urgent/danger)
    final bool canTap = widget.onTap != null;

    List<Color> gradientColors;
    Color shadowColor;
    Color textColor;
    IconData icon;
    String label;

    if (!widget.isActive) {
      // Renew Plan — amber/orange
      gradientColors = const [Color(0xFFF59E0B), Color(0xFFD97706)];
      shadowColor = const Color(0xFFF59E0B);
      textColor = Colors.white;
      icon = Icons.autorenew_rounded;
      label = 'Renew Plan';
    } else if (widget.isDue) {
      // Pay Now — vibrant green
      gradientColors = const [Color(0xFF16A34A), Color(0xFF15803D)];
      shadowColor = const Color(0xFF16A34A);
      textColor = Colors.white;
      icon = Icons.credit_card_rounded;
      label = 'Pay Now';
    } else {
      // Paid — soft muted green-grey (not tappable)
      gradientColors = const [Color(0xFFD1FAE5), Color(0xFFBBF7D0)];
      shadowColor = Colors.transparent;
      textColor = const Color(0xFF059669);
      icon = Icons.check_circle_rounded;
      label = 'Paid';
    }

    return RepaintBoundary(
      child: MouseRegion(
        cursor: canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) { if (canTap) setState(() => _isHovered = true); },
        onExit: (_) { if (canTap) setState(() => _isHovered = false); },
        child: GestureDetector(
          onTapDown: canTap ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: canTap ? (_) {
            setState(() => _isPressed = false);
            widget.onTap!();
          } : null,
          onTapCancel: canTap ? () => setState(() => _isPressed = false) : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isHovered && canTap
                      ? [gradientColors[0], gradientColors[1].withValues(alpha: 0.85)]
                      : gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: canTap && (widget.isDue || !widget.isActive) ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: _isHovered ? 0.5 : 0.3),
                    blurRadius: _isHovered ? 18 : 10,
                    offset: const Offset(0, 5),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


