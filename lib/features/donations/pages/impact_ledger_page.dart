import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/models/donation_model.dart';
import '../../admin/providers/admin_providers.dart';
import '../../../core/localization/app_localization.dart';

class ImpactLedgerPage extends ConsumerWidget {
  const ImpactLedgerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(allDonationsProvider);
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t['view_ledger'] ?? 'Impact Ledger'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Glassmorphism Overlay
          SafeArea(
            child: Column(
              children: [
                // Premium Summary Header
                _buildPremiumHeader(donationsAsync, t, context),

                // Transparency Journal section
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                          child: Row(
                            children: [
                              const Icon(Icons.history_edu_rounded, color: Color(0xFF1E3A8A), size: 28),
                              const SizedBox(width: 12),
                              Text(
                                t['transparency_journal'] ?? 'Transparency Journal',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E3A8A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: donationsAsync.when(
                            data: (donations) {
                              final verified = donations.where((d) => d.status == 'verified').toList()
                                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                              if (verified.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        t['ledger_empty'] ?? 'No entries found in the ledger yet.',
                                        style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                                itemCount: verified.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) => _LedgerEntryCard(donation: verified[index]),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('Error loading journal: $e')),
                          ),
                        ),
                      ],
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

  Widget _buildPremiumHeader(AsyncValue<List<Donation>> donationsAsync, Map<String, String> t, BuildContext context) {
    return donationsAsync.when(
      data: (donations) {
        final verified = donations.where((d) => d.status == 'verified').toList();
        final totalValue = verified.fold<double>(0, (sum, d) {
          if (d.type == DonationType.money) return sum + (d.amount ?? 0);
          return sum + (d.approvedValue ?? 0);
        });
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            children: [
              Text(
                t['total_impact']?.toUpperCase() ?? 'TOTAL COLLECTIVE IMPACT',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12, right: 4),
                    child: Text('৳', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300)),
                  ),
                  Text(
                    NumberFormat('#,##,###').format(totalValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _SummaryBox(label: 'Deliveries', value: '${verified.length}', icon: Icons.local_shipping_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _SummaryBox(label: 'Partners', value: '${verified.map((e) => e.organizationName).toSet().length}', icon: Icons.handshake_rounded)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white))),
      error: (_, __) => const SizedBox(height: 200, child: Center(child: Text('Summary Unavailable', style: TextStyle(color: Colors.white)))),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  final Donation donation;
  const _LedgerEntryCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isMoney = donation.type == DonationType.money;
    final val = isMoney ? (donation.amount ?? 0) : (donation.approvedValue ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isMoney ? const Color(0xFF10B981) : const Color(0xFF3B82F6)).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMoney ? Icons.payments_rounded : Icons.inventory_2_rounded,
                  color: isMoney ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMoney ? 'Financial Contribution' : (donation.itemName ?? donation.itemCategory ?? 'Item Donation'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2937)),
                    ),
                    Text(
                      'Received by ${donation.organizationName}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${NumberFormat('#,###').format(val)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isMoney ? const Color(0xFF059669) : const Color(0xFF1E40AF),
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    dateFormat.format(donation.timestamp),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          if (donation.adminNote != null && donation.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      donation.adminNote!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

