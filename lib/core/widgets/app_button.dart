import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonStyle { primary, secondary, cta }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.fullWidth = true,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.reverse();
  void _onTapUp(TapUpDetails details) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: widget.onPressed == null
                ? AppColors.textSecondary
                : (widget.style == AppButtonStyle.secondary 
                    ? AppColors.primary 
                    : AppColors.white),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );

    BoxDecoration decoration;
    BoxBorder? border;
    
    switch (widget.style) {
      case AppButtonStyle.primary:
        decoration = BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(77), // 0.3 * 255
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
        break;
      case AppButtonStyle.secondary:
        decoration = BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        );
        border = Border.all(color: AppColors.primary, width: 2);
        break;
      case AppButtonStyle.cta:
        decoration = BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withAlpha(77), // 0.3 * 255
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
        break;
    }

    if (widget.onPressed == null) {
      decoration = BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      );
      border = null;
    }

    List<BoxShadow>? currentShadows = decoration.boxShadow;
    if (_isHovered && widget.onPressed != null) {
      if (currentShadows != null && currentShadows.isNotEmpty) {
         currentShadows = [
            BoxShadow(
              color: currentShadows.first.color.withAlpha((currentShadows.first.color.alpha + 50).clamp(0, 255)),
              blurRadius: currentShadows.first.blurRadius + 4,
              offset: Offset(0, currentShadows.first.offset.dy + 2),
            )
         ];
      } else {
         currentShadows = [
            BoxShadow(
               color: AppColors.primary.withAlpha(50),
               blurRadius: 10,
               offset: const Offset(0, 4),
            )
         ];
      }
    }

    return RepaintBoundary(
      child: MouseRegion(
      cursor: widget.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (widget.onPressed != null) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.onPressed != null) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.fullWidth ? double.infinity : null,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: decoration.copyWith(border: border, boxShadow: currentShadows),
              child: buttonContent,
            ),
          ),
          ),
        ),
      ),
    );
  }
}
