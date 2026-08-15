import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/user_providers.dart';
import '../../admin/providers/admin_providers.dart';
import '../../../core/localization/app_localization.dart';

class ImpactCertificatePage extends ConsumerWidget {
  const ImpactCertificatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final donationsAsync = ref.watch(allDonationsProvider);
    final t = ref.watch(translationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E3A8A)),
          onPressed: () => context.pop(),
        ),
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
          
          // Decorative Blobs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: donationsAsync.when(
                data: (donations) {
                  final user = userAsync.value;
                  if (user == null) return const Text('Loading identity...');
                  
                  final verified = donations.where((d) => d.status == 'verified').toList();
                  final totalValue = verified.fold<double>(0, (sum, d) => sum + (d.approvedValue ?? 0));
                  
                  return _CertificateContainer(
                    userName: user.name,
                    totalImpact: totalValue,
                    verifiedDeliveries: verified.length,
                    issueDate: DateTime.now(),
                    t: t,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateContainer extends StatelessWidget {
  final String userName;
  final double totalImpact;
  final int verifiedDeliveries;
  final DateTime issueDate;
  final Map<String, String> t;

  const _CertificateContainer({
    required this.userName,
    required this.totalImpact,
    required this.verifiedDeliveries,
    required this.issueDate,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75,
      child: Stack(
        children: [
          // Certificate Base
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          
          // Ornate Border
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 3), // Gold border
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFFD4AF37), size: 64),
                const SizedBox(height: 24),
                Text(
                  t['certificate_title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t['certificate_subtitle']!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  t['certificate_body']!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t['certificate_footer']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.6),
                ),
                const Spacer(),
                
                // Impact Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('৳${totalImpact.toStringAsFixed(0)}', 'TOTAL GIFTED'),
                    Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
                    _buildStat('$verifiedDeliveries', 'VERIFIED MISSIONS'),
                  ],
                ),
                
                const Spacer(),
                
                // Seal & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(issueDate),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text('Date of Recognition', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    // Gold Seal
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFCFB53B), Color(0xFFA67C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.star, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, letterSpacing: 1, color: Colors.grey),
        ),
      ],
    );
  }
}
