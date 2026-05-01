import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

const _defectData = [
  {'label': 'Scratch', 'count': 8, 'color': 0xFFFF6B6B},
  {'label': 'Dent', 'count': 5, 'color': 0xFFFF9F43},
  {'label': 'Paint', 'count': 12, 'color': 0xFFF368E0},
  {'label': 'Missing', 'count': 3, 'color': 0xFFFF4757},
  {'label': 'Color', 'count': 7, 'color': 0xFF9B59B6},
  {'label': 'Assembly', 'count': 4, 'color': 0xFF00CEC9},
];

enum _Filter { day, month, year }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _Filter _filter = _Filter.month;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final appProvider = context.watch<AppProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 42) / 2;

    // Calculate dynamic defect data
    final Map<String, int> defectCounts = {};
    for (var p in appProvider.rejectedProducts) {
      defectCounts[p.defectType] = (defectCounts[p.defectType] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> dynamicDefectData = defectCounts.entries.map((e) {
      final label = e.key;
      final count = e.value;
      // Assign colors based on label hash or simple mapping
      final colorValue = label.hashCode.abs() % 0xFFFFFF;
      return {
        'label': label,
        'count': count,
        'color': 0xFF000000 | colorValue,
      };
    }).toList();

    // Add dummy data if empty for visual consistency in demo
    if (dynamicDefectData.isEmpty) {
      dynamicDefectData.addAll([
        {'label': 'None', 'count': 0, 'color': 0xFF94A3B8},
      ]);
    }

    final maxCount = dynamicDefectData.isEmpty 
        ? 1 
        : dynamicDefectData.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b).clamp(1, 99999);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: 40,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.glowPurple.withOpacity(0.1),
                ),
              ),
            ),
          ],
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 14,
                        glowColor: colors.glowCyan,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back,
                            color: colors.foreground, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        'Dashboard',
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
                  const SizedBox(height: 16),
                  Row(
                    children: _Filter.values.map((f) {
                      final isActive = f == _filter;
                      final label =
                          f.name[0].toUpperCase() + f.name.substring(1);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? colors.glowCyan
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isActive
                                    ? null
                                    : Border.all(
                                        color: colors.border, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isActive
                                        ? Colors.black
                                        : colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _BigStat(
                        width: cardWidth,
                        icon: Icons.layers_outlined,
                        label: 'Total',
                        value: appProvider.totalProducts,
                        color: colors.glowCyan,
                        colors: colors,
                        isDark: isDark,
                      ),
                      _BigStat(
                        width: cardWidth,
                        icon: Icons.check_circle_outline,
                        label: 'Passed',
                        value: appProvider.passedCount,
                        color: colors.success,
                        colors: colors,
                        isDark: isDark,
                      ),
                      _BigStat(
                        width: cardWidth,
                        icon: Icons.cancel_outlined,
                        label: 'Rejected',
                        value: appProvider.rejectedCount,
                        color: colors.destructive,
                        colors: colors,
                        isDark: isDark,
                      ),
                      _BigStat(
                        width: cardWidth,
                        icon: Icons.star_outline,
                        label: 'Flawless',
                        value: (appProvider.passedCount - 2).clamp(0, 9999),
                        color: colors.glowPurple,
                        colors: colors,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.glowPurple,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Common Defects',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 130,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: dynamicDefectData.map((item) {
                              final count = item['count'] as int;
                              final color = Color(item['color'] as int);
                              final barH = (count / maxCount) * 90;
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$count',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: colors.muted,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: barH.clamp(8.0, 90.0),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.5),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: colors.mutedForeground,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.success,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pass Rate',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.foreground,
                              ),
                            ),
                            Text(
                              appProvider.totalProducts == 0
                                  ? '0%'
                                  : '${((appProvider.passedCount / appProvider.totalProducts) * 100).round()}%',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: colors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: appProvider.totalProducts == 0
                                ? 0
                                : appProvider.passedCount /
                                    appProvider.totalProducts,
                            minHeight: 8,
                            backgroundColor: colors.muted,
                            valueColor:
                                AlwaysStoppedAnimation(colors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final dynamic colors;
  final bool isDark;

  const _BigStat({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    return GlassCard(
      width: width,
      padding: const EdgeInsets.all(18),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: c.mutedForeground),
          ),
        ],
      ),
    );
  }
}
