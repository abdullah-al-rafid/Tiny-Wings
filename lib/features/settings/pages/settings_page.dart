import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_repository.dart';
import '../providers/support_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                            'Settings',
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

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Account Section
                        _buildSectionHeader('ACCOUNT'),
                        const SizedBox(height: 10),
                        _GlassSettingsGroup(tiles: [
                          _SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            iconColor: const Color(0xFF3B82F6),
                            iconBg: const Color(0xFFEFF6FF),
                            onTap: () => context.push('/change-password'),
                          ),
                          _SettingsTile(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notification Preferences',
                            iconColor: const Color(0xFF8B5CF6),
                            iconBg: const Color(0xFFF5F3FF),
                            onTap: () => context.push('/notification-settings'),
                          ),
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Settings',
                            iconColor: const Color(0xFF059669),
                            iconBg: const Color(0xFFECFDF5),
                            onTap: () => context.push('/privacy-settings'),
                          ),
                        ]),

                        const SizedBox(height: 28),

                        const SizedBox(height: 28),

                        // Support Section
                        _buildSectionHeader('SUPPORT'),
                        const SizedBox(height: 10),
                        _GlassSettingsGroup(tiles: [
                          _SettingsTile(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Support',
                            iconColor: const Color(0xFF0EA5E9),
                            iconBg: const Color(0xFFF0F9FF),
                            badgeCount: ref.watch(unreadUserTicketsCountProvider),
                            onTap: () => context.push('/help-support'),
                          ),
                        ]),

                        const SizedBox(height: 12),

                        // Version card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF6B7280)),
                                  ),
                                  const SizedBox(width: 16),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Version', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                      SizedBox(height: 2),
                                      Text('1.0.0', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Logout Button
                        _HoverableLogoutButton(
                          onTap: () => ref.read(authRepositoryProvider).signOut(),
                        ),

                        const SizedBox(height: 40),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _GlassSettingsGroup extends StatelessWidget {
  final List<_SettingsTile> tiles;
  const _GlassSettingsGroup({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: tiles.asMap().entries.map((entry) {
              final idx = entry.key;
              final tile = entry.value;
              return Column(
                children: [
                  tile,
                  if (idx < tiles.length - 1)
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.7), indent: 58),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final Widget? trailing;
  final VoidCallback onTap;
  final int? badgeCount;
  
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.trailing,
    this.badgeCount,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? widget.iconColor.withValues(alpha: 0.15)
                          : widget.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 20),
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
                  if (widget.badgeCount != null && widget.badgeCount! > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.trailing != null) ...[
                    widget.trailing!,
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: _isHovered ? 0.03 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: _isHovered ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
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

class _HoverableLogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverableLogoutButton({required this.onTap});

  @override
  State<_HoverableLogoutButton> createState() => _HoverableLogoutButtonState();
}

class _HoverableLogoutButtonState extends State<_HoverableLogoutButton> {
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
            scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                gradient: _isHovered
                    ? const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: _isHovered ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                  width: 1.5,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: _isHovered ? Colors.white : const Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? Colors.white : const Color(0xFF6B7280),
                    ),
                    child: const Text('Sign Out'),
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