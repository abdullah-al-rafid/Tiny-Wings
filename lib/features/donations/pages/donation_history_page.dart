import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/donation_model.dart';
import '../providers/donation_providers.dart';

class DonationHistoryPage extends ConsumerWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(userDonationsProvider);

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

          // Decorative Blobs
          Positioned(
            top: -80,
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
            bottom: 60,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            'Donation History',
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
                    child: donationsAsync.when(
                      data: (donations) {
                        if (donations.isEmpty) return _buildEmptyState();
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                          itemCount: donations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _DonationCard(donation: donations[index]),
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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 64,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'No donations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your kindness can change someone\'s life.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Donation Card ──────────────────────────────────────────────────────────

class _DonationCard extends StatefulWidget {
  final Donation donation;
  const _DonationCard({required this.donation});

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;
    final bool isMoney = donation.type == DonationType.money;
    final String date = DateFormat('MMM dd, yyyy').format(donation.timestamp);

    final Color accentColor = isMoney ? const Color(0xFF059669) : const Color(0xFF3B82F6);
    final Color accentBg = isMoney ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF);
    final IconData typeIcon = isMoney
        ? Icons.account_balance_wallet_rounded
        : Icons.inventory_2_rounded;

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => _showDonationDetails(context, donation, isMoney),
          child: AnimatedScale(
            scale: _isHovered ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isHovered
                          ? accentColor.withValues(alpha: 0.25)
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
                  child: Row(
                    children: [
                      // Icon Badge
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? accentColor.withValues(alpha: 0.15)
                              : accentBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(typeIcon, color: accentColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      // Main Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donation.organizationName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _isHovered
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 11, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 4),
                                Text(
                                  date,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _StatusBadge(status: donation.status),
                          ],
                        ),
                      ),
                      // Amount / Quantity
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isMoney
                                ? '৳${donation.amount?.toStringAsFixed(0)}'
                                : '${donation.quantity?.toStringAsFixed(1)} ${donation.unit ?? ""}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: accentColor,
                            ),
                          ),
                          if (!isMoney)
                            Text(
                              donation.itemCategory ?? '',
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF9CA3AF)),
                            ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _isHovered
                                  ? accentColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: _isHovered ? accentColor : const Color(0xFF9CA3AF),
                              size: 20,
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
      ),
    );
  }

  void _showDonationDetails(BuildContext context, Donation donation, bool isMoney) {
    final String fullDate =
        DateFormat('MMMM dd, yyyy • hh:mm a').format(donation.timestamp);
    final Color accentColor =
        isMoney ? const Color(0xFF059669) : const Color(0xFF3B82F6);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      isMoney
                          ? Icons.account_balance_wallet_rounded
                          : Icons.inventory_2_rounded,
                      size: 40,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Donation Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _StatusBadge(status: donation.status),
                  const SizedBox(height: 20),
                  // Detail rows
                  _DialogDetailRow(label: 'Organization', value: donation.organizationName),
                  _DialogDetailRow(label: 'Date & Time', value: fullDate),
                  _DialogDetailRow(label: 'Type', value: isMoney ? 'Financial' : 'Physical Items'),
                  if (isMoney) ...[
                    _DialogDetailRow(label: 'Amount', value: '৳${donation.amount?.toStringAsFixed(0)}'),
                    if (donation.paymentMethod != null)
                      _DialogDetailRow(label: 'Payment Method', value: donation.paymentMethod!),
                  ] else ...[
                    _DialogDetailRow(label: 'Category', value: donation.itemCategory ?? 'Unknown'),
                    if (donation.itemName != null)
                      _DialogDetailRow(label: 'Item', value: donation.itemName!),
                    _DialogDetailRow(
                      label: 'Quantity',
                      value: '${donation.quantity?.toStringAsFixed(1)} ${donation.unit ?? ""}',
                    ),
                  ],
                  if (donation.estimatedValue != null || donation.approvedValue != null) ...[
                    Divider(height: 24, color: Colors.grey.withValues(alpha: 0.2)),
                    if (donation.estimatedValue != null)
                      _DialogDetailRow(label: 'Est. Value', value: '৳${donation.estimatedValue!.toStringAsFixed(0)}'),
                    if (donation.approvedValue != null)
                      _DialogDetailRow(label: 'Final Value', value: '৳${donation.approvedValue!.toStringAsFixed(0)}'),
                  ],
                  if (donation.adminNote != null && donation.adminNote!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Note',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            donation.adminNote!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (donation.notes != null && donation.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notes',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          Text(donation.notes!,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF4B5563))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
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

// ─── Status Badge ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        icon = Icons.hourglass_empty_rounded;
        text = 'Pending Review';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        text = 'Rejected';
        break;
      case 'verified':
      default:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        text = 'Verified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}

// ─── Dialog Detail Row ──────────────────────────────────────────────────────

class _DialogDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DialogDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A)),
            ),
          ),
        ],
      ),
    );
  }
}
