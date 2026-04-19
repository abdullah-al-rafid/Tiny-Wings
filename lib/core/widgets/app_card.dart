import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.margin,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null;
    final scale = _isHovered ? (isInteractive ? 1.02 : 1.01) : 1.0;
    final shadowOpacity = _isHovered ? (isInteractive ? 0.12 : 0.08) : 0.04;
    final blurRadius = _isHovered ? (isInteractive ? 20.0 : 15.0) : 10.0;

    return Container(
      margin: widget.margin,
      child: RepaintBoundary(
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: shadowOpacity),
                blurRadius: blurRadius,
                offset: const Offset(0, 5),
              ),
            ],
            border: widget.border ?? Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Padding(
                padding: widget.padding ?? EdgeInsets.all(AppTheme.padding),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
