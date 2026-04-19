import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
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

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    return _HoverableNavItem(
      icon: icon,
      activeIcon: activeIcon,
      label: label,
      isSelected: navigationShell.currentIndex == index,
      onTap: () => _goBranch(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the body to scroll behind the floating nav
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
                    children: [
                      _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                      _buildNavItem(Icons.business_outlined, Icons.business, 'Orgs', 1),
                      _buildNavItem(Icons.favorite_outline, Icons.favorite, 'Needs', 2),
                      _buildNavItem(Icons.notifications_none, Icons.notifications, 'Alerts', 3),
                      _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
                    ],
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

  const _HoverableNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
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

