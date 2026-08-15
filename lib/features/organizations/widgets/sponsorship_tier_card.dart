import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/models/organization_model.dart';

class SponsorshipTierCard extends StatelessWidget {
  final String tierName;
  final double amount;
  final Organization org;
  final Color color;
  final bool isPremium;

  const SponsorshipTierCard({
    super.key,
    required this.tierName,
    required this.amount,
    required this.org,
    required this.color,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData tierIcon;
    Color iconColor;
    if (amount >= 5000) {
      tierIcon = Icons.workspace_premium;
      iconColor = Colors.amber.shade700;
    } else if (amount >= 2500) {
      tierIcon = Icons.stars;
      iconColor = Colors.blueGrey.shade600;
    } else {
      tierIcon = Icons.emoji_events;
      iconColor = Colors.orange.shade800;
    }

    return AppCard(
      color: color,
      border: isPremium ? Border.all(color: Colors.amber, width: 2) : Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
      onTap: () {
        context.push('/sponsorship-checkout', extra: {
          'targetType': 'org',
          'targetId': org.id,
          'targetName': org.name,
          'orgId': org.id,
          'amount': amount,
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(tierIcon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tierName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: iconColor)),
                  const SizedBox(height: 2),
                  const Text('Monthly Pledge', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          Text('৳${amount.toInt()}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: iconColor)),
        ],
      ),
    );
  }
}

