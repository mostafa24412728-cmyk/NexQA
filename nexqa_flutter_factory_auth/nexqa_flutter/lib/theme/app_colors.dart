import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color foreground;
  final Color mutedForeground;
  final Color border;
  final Color muted;
  final Color primary;
  final Color glowCyan;
  final Color glowPurple;
  final Color glowPink;
  final Color success;
  final Color destructive;
  final bool isDark;

  const AppColors({
    required this.background,
    required this.foreground,
    required this.mutedForeground,
    required this.border,
    required this.muted,
    required this.primary,
    required this.glowCyan,
    required this.glowPurple,
    required this.glowPink,
    required this.success,
    required this.destructive,
    required this.isDark,
  });

  static const dark = AppColors(
    background: Color(0xFF000000), // Pure Black
    foreground: Color(0xFFFFFFFF), // White
    mutedForeground: Color(0xFF8899AA), // Gray-Blue
    border: Color(0xFF001E3C), // Dark Blue Border
    muted: Color(0xFF0A0A0F), // Very Dark Blue-Black
    primary: Color(0xFF007BFF), // Blue
    glowCyan: Color(0xFF00E5FF), // Cyan/Light Blue
    glowPurple: Color(0xFF007BFF), // Replaced with Blue
    glowPink: Color(0xFF1E90FF), // Dodger Blue
    success: Color(0xFF00E676),
    destructive: Color(0xFFFF4444),
    isDark: true,
  );

  static const light = AppColors(
    background: Color(0xFFF3F4F6),
    foreground: Color(0xFF111827),
    mutedForeground: Color(0xFF6B7280),
    border: Color(0xFFE5E7EB),
    muted: Color(0xFFE5E7EB),
    primary: Color(0xFF0066CC),
    glowCyan: Color(0xFF0066CC),
    glowPurple: Color(0xFF0066CC),
    glowPink: Color(0xFF0056B3),
    success: Color(0xFF059669),
    destructive: Color(0xFFDC2626),
    isDark: false,
  );
}
