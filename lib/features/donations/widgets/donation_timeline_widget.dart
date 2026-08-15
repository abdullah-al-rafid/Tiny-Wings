import 'package:flutter/material.dart';
import '../../../core/models/donation_model.dart';
import '../../../core/theme/app_colors.dart';

class DonationTimelineWidget extends StatelessWidget {
  final Donation donation;
  const DonationTimelineWidget({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    if (donation.type != DonationType.items) {
      return const SizedBox.shrink();
    }

    final statuses = ['pending', 'verified', 'shipped', 'received'];
    final currentStatusIndex = statuses.indexOf(donation.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Color(0xFF1E3A8A), size: 20),
              SizedBox(width: 12),
              Text(
                'Delivery Timeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimelineStep(
            'Donation Submitted',
            'Your offer is awaiting admin review.',
            isActive: currentStatusIndex >= 0,
            isLast: false,
          ),
          _buildTimelineStep(
            'Verified & Approved',
            'Admin has confirmed the item is needed.',
            isActive: currentStatusIndex >= 1,
            isLast: false,
          ),
          _buildTimelineStep(
            'In Transit',
            'Donation is on its way to the orphanage.',
            isActive: currentStatusIndex >= 2,
            isLast: false,
          ),
          _buildTimelineStep(
            'Delivered & Reported',
            'Item received by orphanage and recorded in Ledger.',
            isActive: currentStatusIndex >= 3,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, {required bool isActive, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade300, width: 2),
              ),
              child: isActive 
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? AppColors.primary : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF1E3A8A) : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? const Color(0xFF4B5563) : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

