import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4A90E2);
  static const Color teal = Color(0xFF2EC4B6);
  static const Color coral = Color(0xFFFF6B6B);
  
  // Neutral Colors
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);
  
  // Utility Colors
  static const Color shadow = Color(0x1A000000);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
