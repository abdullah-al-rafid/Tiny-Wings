import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_providers.dart';
import '../providers/user_impact_providers.dart';
import '../../donations/providers/leaderboard_providers.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../core/widgets/app_image.dart';
import '../../sponsorships/providers/sponsorship_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final authData = ref.watch(authModelProvider);

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
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF93C5FD).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC4B5FD).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF93C5FD).withValues(alpha: 0.25),
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
            child: userProfileAsync.when(
              data: (user) {
                if (authData == null) {
                  return Center(
                    child: _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_circle_outlined, size: 64, color: Color(0xFF9CA3AF)),
                            const SizedBox(height: 16),
                            const Text('Login to see your profile',
                                style: TextStyle(fontSize: 18, color: Color(0xFF4B5563))),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final profileUser = user ?? UserModel(
                  uid: authData.uid,
                  email: authData.email,
                  name: '',
                  phone: '',
                );

                return _buildProfileContent(context, ref, profileUser);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) {
                final errorStr = error.toString().toLowerCase();
                final isPermissionDenied = errorStr.contains('permission deni');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_person_outlined, size: 64, color: AppColors.coral),
                        const SizedBox(height: 24),
                        Text(
                          isPermissionDenied ? 'Profile Access Restricted' : 'Could Not Load Profile',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isPermissionDenied
                              ? 'Your Firebase database rules are likely preventing access to your profile data.'
                              : '$error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        if (isPermissionDenied) ...[
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(userProfileProvider),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero Card ──────────────────────────────────────────
          _GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF93C5FD), Color(0xFF818CF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: getAppImageProvider(user.profilePictureUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty)
                            ? const Icon(Icons.person_rounded, size: 42, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name.isNotEmpty ? user.name : 'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                if (user.isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.type,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                      _RankBadge(uid: user.uid),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Edit Profile Button
                  _HoverableButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    onTap: () => context.push('/edit-profile'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── About Me ───────────────────────────────────────────
          _SectionLabel(label: 'ABOUT ME'),
          const SizedBox(height: 10),
          _GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: user.phone),
                  _DetailRow(icon: Icons.work_outline_rounded, label: 'Profession', value: user.profession),
                  _DetailRow(icon: Icons.star_outline_rounded, label: 'Skills', value: user.skills),
                  _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: user.address),
                  _DetailRow(icon: Icons.bloodtype_outlined, label: 'Blood Group', value: user.bloodGroup),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        user.bio!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (!user.isAdmin) ...[
            const SizedBox(height: 18),

            // ── My Impact ──────────────────────────────────────────
            _SectionLabel(label: 'MY IMPACT'),
            const SizedBox(height: 10),
            ref.watch(userImpactProvider).when(
              data: (impact) {
                final activeSubsAsync = ref.watch(activeUserSubscriptionsProvider);
                final activeSubCount = activeSubsAsync.value?.length ?? 0;
                return Row(
                  children: [
                    Expanded(
                      child: _ImpactStatCard(
                        val: '৳${impact.totalContributed.toStringAsFixed(0)}',
                        label: 'Total Contribution',
                        icon: Icons.volunteer_activism_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ImpactStatCard(
                        val: '$activeSubCount',
                        label: 'Sponsorships',
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFEC4899),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _ImpactStatCard(
                        val: '0',
                        label: 'Volunteer Apps',
                        icon: Icons.groups_rounded,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Impact stats unavailable'),
            ),
          ],

          const SizedBox(height: 18),

          // ── Quick Actions ──────────────────────────────────────
          _SectionLabel(label: 'QUICK ACTIONS'),
          const SizedBox(height: 10),
          _GlassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.favorite_rounded,
                    label: 'Donation History',
                    iconColor: const Color(0xFFEC4899),
                    iconBg: const Color(0xFFFDF2F8),
                    onTap: () => context.push('/donation-history'),
                  ),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.8), indent: 58),
                  _ActionTile(
                    icon: Icons.handshake_rounded,
                    label: 'My Sponsorships',
                    iconColor: const Color(0xFF8B5CF6),
                    iconBg: const Color(0xFFF5F3FF),
                    onTap: () => context.push('/my-sponsorships'),
                  ),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.8), indent: 58),
                  _ActionTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'My Applications',
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFECFDF5),
                    onTap: () {},
                  ),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.8), indent: 58),
                  _ActionTile(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    iconColor: const Color(0xFF6B7280),
                    iconBg: const Color(0xFFF9FAFB),
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────── Supporting Widgets ────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _DetailRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              Text(
                hasValue ? value! : 'Not provided',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasValue ? const Color(0xFF1E3A8A) : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactStatCard extends StatelessWidget {
  final String val;
  final String label;
  final IconData icon;
  final Color color;

  const _ImpactStatCard({
    required this.val,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                val,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: _isHovered ? Colors.white.withValues(alpha: 0.45) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _isHovered ? widget.iconColor.withValues(alpha: 0.15) : widget.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, size: 20, color: widget.iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isHovered ? const Color(0xFF1E3A8A) : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isHovered ? 0.03 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: _isHovered ? widget.iconColor : const Color(0xFF9CA3AF),
                      size: 22,
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

class _HoverableButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HoverableButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<_HoverableButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isHovered
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: _isHovered ? null : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered ? const Color(0xFF1D4ED8) : const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 18, color: _isHovered ? Colors.white : const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? Colors.white : const Color(0xFF3B82F6),
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

class _RankBadge extends ConsumerWidget {
  final String uid;
  const _RankBadge({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.maybeWhen(
      data: (data) {
        final allTime = data.allTime;
        final index = allTime.indexWhere((e) => e.userId == uid);
        if (index == -1) return const SizedBox.shrink();

        final rank = index + 1;
        List<Color> gradientColors;
        IconData iconData;
        String label;

        if (rank == 1) {
          gradientColors = const [Color(0xFFFFDF00), Color(0xFFD4AF37)];
          iconData = Icons.emoji_events_rounded;
          label = '1st';
        } else if (rank == 2) {
          gradientColors = const [Color(0xFFE0E0E0), Color(0xFFA9A9A9)];
          iconData = Icons.military_tech_rounded;
          label = '2nd';
        } else if (rank == 3) {
          gradientColors = const [Color(0xFFCD7F32), Color(0xFF8B4513)];
          iconData = Icons.military_tech_rounded;
          label = '3rd';
        } else if (rank <= 10) {
          gradientColors = const [Color(0xFF9333EA), Color(0xFF6B21A8)];
          iconData = Icons.workspace_premium_rounded;
          label = 'Top 10';
        } else if (rank <= 50) {
          gradientColors = const [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
          iconData = Icons.star_rounded;
          label = 'Top 50';
        } else {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(iconData, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: gradientColors.last,
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}