import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../profile/providers/user_providers.dart';
import '../../profile/data/user_repository.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  bool _isLoading = false;

  Future<void> _updatePreference(String field, bool value) async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile == null) return;

    setState(() => _isLoading = true);

    try {
      UserModel updatedUser;
      switch (field) {
        case 'donationStatus':
          updatedUser = userProfile.copyWith(notifyDonationStatus: value);
          break;
        case 'sponsorships':
          updatedUser = userProfile.copyWith(notifySponsorships: value);
          break;
        case 'newNeeds':
          updatedUser = userProfile.copyWith(notifyNewNeeds: value);
          break;
        case 'marketing':
          updatedUser = userProfile.copyWith(notifyMarketing: value);
          break;
        default:
          return;
      }

      await ref.read(userRepositoryProvider).saveUserProfile(updatedUser);
      ref.invalidate(userProfileProvider);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: $e'),
            backgroundColor: AppColors.coral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).value;

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
            right: -60,
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
                color: const Color(0xFFC4B5FD).withValues(alpha: 0.35),
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
                // Glassmorphic AppBar
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
                            'Notification Preferences',
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

                if (userProfile == null)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const Text(
                          'Select the types of alerts you want to receive. We only send notifications that matter to you.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildGlassSettingTile(
                          title: 'Donation Updates',
                          subtitle: 'Alerts when your donation is verified or if more info is needed.',
                          icon: Icons.volunteer_activism_outlined,
                          value: userProfile.notifyDonationStatus,
                          onChanged: _isLoading ? null : (val) => _updatePreference('donationStatus', val),
                        ),
                        const SizedBox(height: 16),
                        _buildGlassSettingTile(
                          title: 'Sponsorship Reminders',
                          subtitle: 'Monthly prompts to renew your recurring sponsorships.',
                          icon: Icons.calendar_month_outlined,
                          value: userProfile.notifySponsorships,
                          onChanged: _isLoading ? null : (val) => _updatePreference('sponsorships', val),
                        ),
                        const SizedBox(height: 16),
                        _buildGlassSettingTile(
                          title: 'New Urgent Needs',
                          subtitle: 'Notifications for new urgent needs from your followed organizations.',
                          icon: Icons.campaign_outlined,
                          value: userProfile.notifyNewNeeds,
                          onChanged: _isLoading ? null : (val) => _updatePreference('newNeeds', val),
                        ),
                        const SizedBox(height: 16),
                        _buildGlassSettingTile(
                          title: 'Impact Stories & Marketing',
                          subtitle: 'Stay updated with impact updates and community news.',
                          icon: Icons.auto_awesome_outlined,
                          value: userProfile.notifyMarketing,
                          onChanged: _isLoading ? null : (val) => _updatePreference('marketing', val),
                        ),
                        
                        const SizedBox(height: 32),
                        _buildInfoCard(
                          icon: Icons.notifications_active_outlined,
                          text: 'These settings control push notifications on your device. You can change them anytime.',
                        ),
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

  Widget _buildGlassSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E3A8A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
