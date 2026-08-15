import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/providers/notification_providers.dart';
import '../../features/profile/providers/user_providers.dart';
import '../models/user_model.dart';
import '../localization/app_localization.dart';

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index, {int badgeCount = 0, VoidCallback? onTapOverride}) {
    return _HoverableNavItem(
      icon: icon,
      activeIcon: activeIcon,
      label: label,
      isSelected: navigationShell.currentIndex == index,
      onTap: onTapOverride ?? () => _goBranch(index),
      badgeCount: badgeCount,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    
    final t = ref.watch(translationProvider);
    
    // Default items (Donor/Normal)
    List<Widget> navItems = [
      _buildNavItem(Icons.home_outlined, Icons.home, t['home'] ?? 'Home', 0),
      _buildNavItem(Icons.business_outlined, Icons.business, t['organizations'] ?? 'Organizations', 1),
      _buildNavItem(Icons.favorite_outline, Icons.favorite, t['impact'] ?? 'Impact', 2),
      _buildNavItem(
        unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, 
        Icons.notifications_rounded, 
        'Alerts', 
        3, 
        badgeCount: unreadCount,
      ),
      _buildNavItem(Icons.person_outline, Icons.person, t['profile'] ?? 'Profile', 4),
    ];

    // Customize per role if profile is loaded
    if (userProfile != null) {
      if (userProfile.role == UserRole.admin) {
        navItems = [
          _buildNavItem(Icons.home_filled, Icons.home, 'Home', 0),
          _buildNavItem(Icons.domain_verification_rounded, Icons.business, 'Manage', 1),
          _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Stats', 2),
          _buildNavItem(
            unreadCount > 0 ? Icons.notifications_active : Icons.notifications, 
            Icons.notifications, 
            'Alerts', 
            3, 
            badgeCount: unreadCount,
          ),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
        ];
      } else if (userProfile.role == UserRole.orphanageAdmin) {
        navItems = [
          _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
          _buildNavItem(
            Icons.business_outlined, 
            Icons.business, 
            'My Org', 
            1,
            onTapOverride: () {
              final orgId = userProfile.assignedOrphanageId ?? userProfile.organizationId;
              if (orgId != null) {
                context.go('/organizations/$orgId');
              } else {
                _goBranch(1);
              }
            },
          ),
          _buildNavItem(Icons.add_box_outlined, Icons.add_box, 'Needs', 2),
          _buildNavItem(
            unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, 
            Icons.notifications_rounded, 
            'Alerts', 
            3, 
            badgeCount: unreadCount,
          ),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
        ];
      } else if (userProfile.role == UserRole.volunteer) {
        navItems = [
          _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
          _buildNavItem(Icons.volunteer_activism_outlined, Icons.volunteer_activism, 'Tasks', 1),
          _buildNavItem(Icons.explore_outlined, Icons.explore, 'Explore', 2),
          _buildNavItem(
            unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, 
            Icons.notifications_rounded, 
            'Alerts', 
            3, 
            badgeCount: unreadCount,
          ),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
        ];
      }
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: navItems,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _HoverableNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<_HoverableNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isHovered && !widget.isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: widget.isSelected ? 16 : (_isHovered ? 12 : 8), vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected 
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.15) 
                  : (_isHovered ? const Color(0xFF3B82F6).withValues(alpha: 0.05) : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.isSelected ? widget.activeIcon : widget.icon,
                        key: ValueKey<bool>(widget.isSelected),
                        color: widget.isSelected 
                            ? const Color(0xFF1E3A8A) 
                            : (_isHovered ? const Color(0xFF3B82F6) : const Color(0xFF6B7280)),
                        size: 24,
                      ),
                    ),
                    if (widget.badgeCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

