import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/organization_model.dart';
import '../../organizations/providers/organization_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../profile/providers/user_providers.dart';
import '../../profile/providers/user_impact_providers.dart';
import '../../donations/providers/leaderboard_providers.dart';
import '../../donations/widgets/premium_leaderboard_card.dart';
import '../../../core/widgets/app_image.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final nameValue = userProfileAsync.value?.name;
    final userName = (nameValue != null && nameValue.isNotEmpty) ? nameValue : 'User';

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Decorative Abstract Blobs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF93C5FD).withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD8B4FE).withOpacity(0.4),
              ),
            ),
          ),
          // Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          
          SafeArea(
            child: RepaintBoundary(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing, 
                  vertical: AppTheme.padding,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Welcome back, $userName',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick Actions (Hidden for Admin)
                  if (!(userProfileAsync.value?.isAdmin ?? false)) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickAction(context, Icons.favorite_outline, 'Donate', onTap: () => context.push('/donate')),
                              _buildQuickAction(context, Icons.handshake_outlined, 'Sponsor', onTap: () => context.push('/sponsorships')),
                              _buildQuickAction(context, Icons.group_outlined, 'Volunteer', onTap: () => context.push('/volunteer')),
                              _buildQuickAction(context, Icons.trending_up, 'Needs', onTap: () => context.go('/needs')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],

                  // Your Impact Section (Hidden for Admin)
                  if (!(userProfileAsync.value?.isAdmin ?? false)) ...[
                    Text(
                      'Your Impact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ref.watch(userImpactProvider).when(
                      data: (impact) => Row(
                        children: [
                          Expanded(child: _buildImpactCard(context, '${impact.childrenSupported}', 'Children\nSupported')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildImpactCard(context, '${impact.activeCampaigns}', 'Active\nCampaigns')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildImpactCard(context, '৳${impact.totalContributed.toStringAsFixed(0)}', 'Total\nContribution')),
                        ],
                      ),
                      loading: () => const Center(child: LinearProgressIndicator()),
                      error: (e, _) => Text('Impact stats unavailable: $e', style: const TextStyle(fontSize: 10, color: AppColors.coral)),
                    ),
                    const SizedBox(height: 36),
                  ],
                  
                  if (userProfileAsync.value?.isAdmin ?? false) ...[
                    AppCard(
                      color: AppColors.primary,
                      onTap: () => context.push('/admin-dashboard'),
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, color: AppColors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Admin Dashboard',
                                  style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Manage organizations and applications',
                                  style: TextStyle(color: AppColors.white.withValues(alpha: 0.8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                   // Leaderboard Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Contributors',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/leaderboard'),
                        child: const Text('View All', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ref.watch(leaderboardProvider).when(
                    data: (data) => _buildTopDonors(context, data.allTime, userProfileAsync.value?.uid),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => const Text('Leaderboard currently unavailable'),
                  ),
                  const SizedBox(height: 36),

                  // Featured Organizations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Organizations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/organizations'),
                        child: const Text(
                          'View All', 
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  ref.watch(organizationsProvider).when(
                    data: (organizations) {
                      final featured = organizations.where((o) => o.isFeatured).toList();
                      
                      if (featured.isEmpty) {
                        if (organizations.isNotEmpty) {
                          return _buildFeaturedCard(context, organizations.first);
                        }
                        return const Center(child: Text('Coming soon!'));
                      }
                      
                      return Column(
                        children: featured.map((org) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildFeaturedCard(context, org),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Unable to load organizations: $e')),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return _HoverableQuickAction(
      icon: icon,
      label: label,
      onTap: onTap,
    );
  }

  Widget _buildImpactCard(BuildContext context, String value, String label) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Organization org) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Asset Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius)),
            child: Container(
              height: 160,
              child: AppImage(
                imageUrl: org.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.background,
                  child: const Icon(Icons.business, size: 48, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      org.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (org.isVerified)
                      const Icon(Icons.check_circle, color: AppColors.teal, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  org.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  org.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),
                AppButton(
                  style: AppButtonStyle.secondary,
                  text: 'View Details',
                  onPressed: () {
                    context.push('/organizations/${org.id}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDonors(BuildContext context, List<LeaderboardEntry> donors, String? currentUserId) {
    if (donors.isEmpty) {
      return const Center(child: Text('Be the first to donate!', style: TextStyle(color: AppColors.textSecondary)));
    }
    
    final double topAmount = donors.first.totalAmount;
    final List<Widget> cards = [];
    
    // Top 3
    final topThree = donors.take(3).toList();
    for (int i = 0; i < topThree.length; i++) {
      final entry = topThree[i];
      cards.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PremiumLeaderboardCard(
            entry: entry,
            rank: i + 1,
            topAmount: topAmount,
            isCurrentUser: entry.userId == currentUserId,
          ),
        ),
      );
    }
    
    // Check if current user is outside Top 3
    if (currentUserId != null) {
      int userRankIndex = donors.indexWhere((d) => d.userId == currentUserId);
      
      // If user is ranked but not in Top 3
      if (userRankIndex >= 3) {
        cards.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('YOUR RANKING', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          )
        );
        cards.add(
          PremiumLeaderboardCard(
            entry: donors[userRankIndex],
            rank: userRankIndex + 1,
            topAmount: topAmount,
            isCurrentUser: true,
          ),
        );
      }
      // If user is not ranked at all
      else if (userRankIndex == -1) {
        cards.add(
          Padding(
             padding: const EdgeInsets.only(top: 8.0),
             child: AppCard(
               color: AppColors.teal.withValues(alpha: 0.05),
               border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text(
                     'Not Ranked Yet',
                     style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                   ),
                   Text(
                     'Donate ৳1 to join!',
                     style: TextStyle(color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.bold)
                   )
                 ]
               )
             )
          )
        );
      }
    }

    return Column(children: cards);
  }
}

class _HoverableQuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HoverableQuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_HoverableQuickAction> createState() => _HoverableQuickActionState();
}

class _HoverableQuickActionState extends State<_HoverableQuickAction> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.90 : (_isHovered ? 1.05 : 1.0);
    final shadowOpacity = _isHovered ? 0.4 : 0.15;
    final blurRadius = _isHovered ? 25.0 : 15.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(shadowOpacity),
                      blurRadius: blurRadius,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon, 
                  size: 28, 
                  color: _isHovered ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _isHovered ? const Color(0xFF1E3A8A) : const Color(0xFF4B5563),
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}