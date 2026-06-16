import os, re

base = r'c:\Users\win\Downloads\NexQA\nexqa_flutter_factory_auth\nexqa_flutter\lib'

app_colors = """import 'package:flutter/material.dart';

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
"""
with open(os.path.join(base, 'theme', 'app_colors.dart'), 'w', encoding='utf-8') as f:
    f.write(app_colors)

def refactor_screen(filename, replacements):
    path = os.path.join(base, 'screens', filename)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "import '../providers/theme_provider.dart';" not in content:
        content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport '../providers/theme_provider.dart';\nimport '../theme/app_colors.dart';")
    
    content = re.sub(r'// Pixel-perfect theme colors.*?\n(const [a-zA-Z]+ = Color\(0x[A-F0-9]+\);\n)+', '', content, flags=re.DOTALL)
    content = re.sub(r'// Colors for the new pixel-perfect premium theme.*?\n(const [a-zA-Z]+ = Color\(0x[A-F0-9]+\);\n)+', '', content, flags=re.DOTALL)
    
    content = re.sub(r'(Widget build\(BuildContext context\) {)', r'\1\n    final _c = context.watch<ThemeProvider>().colors;', content)
    
    for old, new in replacements.items():
        content = content.replace(old, new)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

replacements = {
    'bgColor': '_c.background',
    'cardColor': '_c.muted',
    'fieldColor': '_c.muted',
    'primaryBlue': '_c.primary',
    'successGreen': '_c.success',
    'dangerRed': '_c.destructive',
    'textPrimary': '_c.foreground',
    'textSecondary': '_c.mutedForeground',
    'borderColor': '_c.border'
}

refactor_screen('home_screen.dart', replacements)
refactor_screen('dashboard_screen.dart', replacements)
refactor_screen('login_screen.dart', replacements)
refactor_screen('signup_screen.dart', replacements)
print('UI Refactored Successfully')
