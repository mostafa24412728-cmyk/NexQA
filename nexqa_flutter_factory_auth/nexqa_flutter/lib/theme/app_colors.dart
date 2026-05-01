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
    background: Color(0xFF060912),
    foreground: Color(0xFFF0F4FF),
    mutedForeground: Color(0xFF6B7280),
    border: Color(0xFF1E2433),
    muted: Color(0xFF111827),
    primary: Color(0xFF00E5FF),
    glowCyan: Color(0xFF00E5FF),
    glowPurple: Color(0xFF8A2BE2),
    glowPink: Color(0xFFFF1493),
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
    glowPurple: Color(0xFF7C3AED),
    glowPink: Color(0xFFEC4899),
    success: Color(0xFF059669),
    destructive: Color(0xFFDC2626),
    isDark: false,
  );
}
