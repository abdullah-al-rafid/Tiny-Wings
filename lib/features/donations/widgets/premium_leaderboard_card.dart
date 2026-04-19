import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_providers.dart';
import '../../sponsorships/providers/sponsorship_providers.dart';

class PremiumLeaderboardCard extends ConsumerWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double topAmount;
  final bool isCurrentUser;

  const PremiumLeaderboardCard({
    super.key,
    required this.entry,
    required this.rank,
    required this.topAmount,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isTopThree = rank <= 3;
    
    final allSubsAsync = ref.watch(allSubscriptionsProvider);
    final userSubs = allSubsAsync.value?.where((s) => s.donorId == entry.userId && s.status == 'active').toList() ?? [];
    final isSponsor = userSubs.isNotEmpty;
    
    final maxOrgAmount = userSubs.where((s) => s.targetType == 'org' || s.orgId.isNotEmpty).fold<double>(0, (max, s) => s.amount > max ? s.amount : max);
    final isGoldSponsor = maxOrgAmount >= 5000;
    final isSilverSponsor = maxOrgAmount >= 2500 && maxOrgAmount < 5000;
    final isBronzeSponsor = maxOrgAmount > 0 && maxOrgAmount < 2500;
    final isChildSponsor = userSubs.any((s) => s.targetType == 'child');

    Color sponsorColor = Colors.transparent;
    Color sponsorHaloColor = Colors.transparent;
    IconData sponsorIcon = Icons.stars;

    if (isGoldSponsor) {
      sponsorColor = Colors.amber.shade700;
      sponsorHaloColor = Colors.amberAccent;
      sponsorIcon = Icons.workspace_premium;
    } else if (isSilverSponsor) {
      sponsorColor = Colors.blueGrey.shade600;
      sponsorHaloColor = Colors.blueGrey.shade300;
      sponsorIcon = Icons.stars;
    } else if (isBronzeSponsor) {
      sponsorColor = Colors.orange.shade800;
      sponsorHaloColor = Colors.orangeAccent;
      sponsorIcon = Icons.emoji_events;
    } else if (isChildSponsor) {
      sponsorColor = Colors.lightBlue.shade700;
      sponsorHaloColor = Colors.lightBlueAccent;
      sponsorIcon = Icons.child_care;
    }
    
    // Define Gradients and Highlights
    LinearGradient? backgroundGradient;
    Color iconColor = AppColors.textSecondary.withValues(alpha: 0.5);
    Color borderColor = Colors.transparent;

    if (rank == 1) {
      backgroundGradient = const LinearGradient(
        colors: [Color(0xFFFFF9E6), Color(0xFFFFE066)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      iconColor = const Color(0xFFB8860B); // Gold text
      borderColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      backgroundGradient = const LinearGradient(
        colors: [Color(0xFFF3F4F6), Color(0xFFD1D5DB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      iconColor = const Color(0xFF6B7280); // Silver text
      borderColor = const Color(0xFF9CA3AF);
    } else if (rank == 3) {
      backgroundGradient = const LinearGradient(
        colors: [Color(0xFFFFF5ED), Color(0xFFE5B382)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      iconColor = const Color(0xFF9C4F15); // Bronze text
      borderColor = const Color(0xFFCD7F32);
    }

    if (isCurrentUser && !isTopThree) {
      backgroundGradient = LinearGradient(
        colors: [AppColors.teal.withValues(alpha: 0.05), AppColors.teal.withValues(alpha: 0.15)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      borderColor = AppColors.teal.withValues(alpha: 0.3);
    }

    // Determine deficit and message
    double deficit = topAmount - entry.totalAmount;
    String motivationMessage = '';
    
    if (isCurrentUser) {
      if (rank == 1) {
        motivationMessage = '🏆 Incomparable generosity! You are leading the pack.';
      } else {
        motivationMessage = 'Only ৳${deficit.toStringAsFixed(0)} away from #1! Keep going! 🚀';
      }
    } else if (rank == 1) {
      motivationMessage = 'Reigning Champion';
    } else if (rank == 2) {
      motivationMessage = 'Almost there! Needs ৳${deficit.toStringAsFixed(0)} for #1';
    } else if (rank == 3) {
      motivationMessage = 'Rising Star! Needs ৳${deficit.toStringAsFixed(0)} for #1';
    } else {
      motivationMessage = 'Needs ৳${deficit.toStringAsFixed(0)} to reach the top.';
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          color: backgroundGradient == null ? AppColors.white : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentUser && isTopThree ? AppColors.teal : borderColor,
            width: isCurrentUser ? 2 : 1,
          ),
          boxShadow: isTopThree
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTopThree ? AppColors.white.withValues(alpha: 0.5) : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: iconColor, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Avatar with Sponsor Halo
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: isSponsor ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: sponsorHaloColor,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                    border: Border.all(
                        color: sponsorHaloColor,
                        width: 3,
                    ),
                  ) : null,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: entry.profilePictureUrl != null && entry.profilePictureUrl!.isNotEmpty
                        ? getAppImageProvider(entry.profilePictureUrl!)
                        : null,
                    backgroundColor: AppColors.background,
                    child: entry.profilePictureUrl == null || entry.profilePictureUrl!.isEmpty
                        ? const Icon(Icons.person_outline, size: 24, color: AppColors.textSecondary)
                        : null,
                  ),
                ),
                if (isSponsor)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        sponsorIcon,
                        size: 16,
                        color: sponsorColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Name & Motivation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.userName,
                          style: TextStyle(
                            fontWeight: isTopThree || isCurrentUser ? FontWeight.bold : FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                   Text(
                    motivationMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: isTopThree ? iconColor.withValues(alpha: 0.8) : AppColors.textSecondary,
                      fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 10, color: isTopThree ? iconColor.withValues(alpha: 0.7) : AppColors.primary.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.paymentCount} Contributions',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isTopThree ? iconColor.withValues(alpha: 0.7) : AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Amount & Breakdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ref.watch(leaderboardTypeProvider) == LeaderboardType.sponsor
                  ? Text(
                      '৳${entry.sponsorshipAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isTopThree ? iconColor : AppColors.teal,
                      ),
                    )
                  : ref.watch(leaderboardTypeProvider) == LeaderboardType.donation
                      ? Text(
                          '৳${entry.donationAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isTopThree ? iconColor : AppColors.teal,
                          ),
                        )
                      : Text(
                          '৳${entry.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isTopThree ? iconColor : AppColors.teal,
                          ),
                        ),
                
                // Always show breakdown in Total mode if any contribution exists
                if (ref.watch(leaderboardTypeProvider) == LeaderboardType.total && 
                    (entry.donationAmount > 0 || entry.sponsorshipAmount > 0))
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (entry.donationAmount > 0)
                          Text(
                            '৳${entry.donationAmount.toStringAsFixed(0)}D',
                            style: TextStyle(
                              fontSize: 9,
                              color: (isTopThree ? iconColor : AppColors.textSecondary).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (entry.donationAmount > 0 && entry.sponsorshipAmount > 0)
                          Text(
                            ' + ',
                            style: TextStyle(
                              fontSize: 9,
                              color: (isTopThree ? iconColor : AppColors.textSecondary).withValues(alpha: 0.7),
                            ),
                          ),
                        if (entry.sponsorshipAmount > 0)
                          Text(
                            '৳${entry.sponsorshipAmount.toStringAsFixed(0)}S',
                            style: TextStyle(
                              fontSize: 9,
                              color: (isTopThree ? iconColor : AppColors.textSecondary).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
