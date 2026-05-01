import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoAnalysis = true;
  bool _highRes = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: 60,
              right: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.glowPink.withOpacity(0.1),
                ),
              ),
            ),
          ],
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 14,
                        glowColor: colors.glowPink,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back,
                            color: colors.foreground, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.foreground,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.glowCyan,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APPEARANCE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _ThemeOption(
                              label: 'Dark',
                              icon: Icons.dark_mode,
                              isSelected:
                                  themeProvider.preference == ThemePreference.dark,
                              previewColor: const Color(0xFF060912),
                              iconColor: const Color(0xFF00E5FF),
                              accentColor: colors.glowCyan,
                              onTap: () => themeProvider
                                  .setPreference(ThemePreference.dark),
                            ),
                            const SizedBox(width: 12),
                            _ThemeOption(
                              label: 'Light',
                              icon: Icons.light_mode,
                              isSelected: themeProvider.preference ==
                                  ThemePreference.light,
                              previewColor: const Color(0xFFF3F4F6),
                              iconColor: const Color(0xFF0066CC),
                              accentColor: colors.primary,
                              onTap: () => themeProvider
                                  .setPreference(ThemePreference.light),
                            ),
                            const SizedBox(width: 12),
                            _ThemeOption(
                              label: 'System',
                              icon: Icons.phone_android,
                              isSelected: themeProvider.preference ==
                                  ThemePreference.system,
                              previewColor: isDark
                                  ? const Color(0xFF060912)
                                  : const Color(0xFFF3F4F6),
                              iconColor: isDark
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF0066CC),
                              accentColor: colors.glowPurple,
                              onTap: () => themeProvider
                                  .setPreference(ThemePreference.system),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.glowCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: colors.glowCyan.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.glowCyan,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text.rich(
                                TextSpan(
                                  text: 'Currently: ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colors.mutedForeground,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: isDark ? 'Dark Mode' : 'Light Mode',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colors.glowCyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.glowPurple,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INSPECTION',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Toggle(
                          label: 'Auto AI Analysis',
                          description: 'Automatically analyze when photo is taken',
                          value: _autoAnalysis,
                          color: colors.glowPurple,
                          onChanged: (v) => setState(() => _autoAnalysis = v),
                          colors: colors,
                        ),
                        Container(height: 0.5, color: colors.border, margin: const EdgeInsets.symmetric(vertical: 12)),
                        _Toggle(
                          label: 'High Resolution',
                          description: 'Use maximum camera quality',
                          value: _highRes,
                          color: colors.glowCyan,
                          onChanged: (v) => setState(() => _highRes = v),
                          colors: colors,
                        ),
                        Container(height: 0.5, color: colors.border, margin: const EdgeInsets.symmetric(vertical: 12)),
                        _Toggle(
                          label: 'Notifications',
                          description: 'Alerts for inspection results',
                          value: _notifications,
                          color: colors.glowPink,
                          onChanged: (v) => setState(() => _notifications = v),
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.glowCyan,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colors.glowCyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.factory_outlined,
                                  color: colors.glowCyan, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.watch<AuthProvider>().factoryName ?? 'Factory',
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: colors.foreground,
                                    ),
                                  ),
                                  Text(
                                    'Signed in factory account',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await context.read<AuthProvider>().signOut();
                              if (context.mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            },
                            icon: Icon(Icons.logout, color: colors.destructive),
                            label: Text(
                              'Log Out',
                              style: GoogleFonts.inter(
                                color: colors.destructive,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.destructive.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.glowPink,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ABOUT',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colors.glowCyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.qr_code_scanner,
                                  color: colors.glowCyan, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NexQA',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: colors.foreground,
                                  ),
                                ),
                                Text(
                                  'AI Quality Assurance',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(height: 0.5, color: colors.border),
                        const SizedBox(height: 12),
                        _AboutRow(label: 'Version', value: '1.0.0', icon: Icons.info_outline, colors: colors),
                        _AboutRow(label: 'Build', value: '2026.04.11', icon: Icons.build_outlined, colors: colors),
                        _AboutRow(label: 'AI Model', value: 'NexQA Vision v2', icon: Icons.memory_outlined, colors: colors),
                        _AboutRow(label: 'Developer', value: 'NexQA Labs', icon: Icons.business_outlined, colors: colors),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color previewColor;
  final Color iconColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.previewColor,
    required this.iconColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 12)]
                      : null,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isSelected ? accentColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;
  final dynamic colors;

  const _Toggle({
    required this.label,
    required this.description,
    required this.value,
    required this.color,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: c.foreground,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                    fontSize: 12, color: c.mutedForeground),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          activeTrackColor: color.withOpacity(0.4),
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final dynamic colors;

  const _AboutRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: c.mutedForeground, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: c.mutedForeground),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
