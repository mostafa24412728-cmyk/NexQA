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
    background: Color(0xFF0B0E14),
    foreground: Color(0xFFFFFFFF),
    mutedForeground: Color(0xFF9CA3AF),
    border: Color(0xFF2C323D),
    muted: Color(0xFF1C212B),
    primary: Color(0xFF3B82F6),
    glowCyan: Color(0xFF3B82F6),
    glowPurple: Color(0xFF3B82F6),
    glowPink: Color(0xFF3B82F6),
    success: Color(0xFF10B981),
    destructive: Color(0xFFEF4444),
    isDark: true,
  );

  static const light = AppColors(
    background: Color(0xFFF3F4F6),
    foreground: Color(0xFF111827),
    mutedForeground: Color(0xFF6B7280),
    border: Color(0xFFE5E7EB),
    muted: Color(0xFFFFFFFF),
    primary: Color(0xFF3B82F6),
    glowCyan: Color(0xFF3B82F6),
    glowPurple: Color(0xFF3B82F6),
    glowPink: Color(0xFF3B82F6),
    success: Color(0xFF059669),
    destructive: Color(0xFFDC2626),
    isDark: false,
  );
}
