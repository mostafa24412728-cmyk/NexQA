import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';


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
    final _c = context.watch<ThemeProvider>().colors;
    final appProvider = context.watch<AppProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 16) / 2;

    // Calculate dynamic defect data
    final Map<String, int> defectCounts = {};
    for (var p in appProvider.rejectedProducts) {
      final type = p.defectType;
      defectCounts[type] = (defectCounts[type] ?? 0) + 1;
    }

    int maxCount = 1;
    String mostCommonDefect = 'لا يوجد عيوب';
    if (defectCounts.isNotEmpty) {
      defectCounts.forEach((label, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonDefect = label;
        }
      });
      // Fallback for demo visually like the screenshot
      if (defectCounts.length == 1 && defectCounts.values.first == 1) {
         mostCommonDefect = defectCounts.keys.first;
      }
    } else {
       // Mock for UI presentation if empty
       mostCommonDefect = 'عقدة حية (سليمة)';
    }

    final passRate = appProvider.totalProducts == 0
        ? 0.0
        : (appProvider.passedCount / appProvider.totalProducts);

    return Scaffold(
      backgroundColor: _c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.muted,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _c.border),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: _c.mutedForeground, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _c.foreground,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44), // balance
                ],
              ),
              const SizedBox(height: 24),

              // Filter Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C212B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _Filter.values.map((f) {
                    final isActive = f == _filter;
                    final label = f.name[0].toUpperCase() + f.name.substring(1);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isActive ? _c.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                color: isActive ? Colors.black : _c.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _BigStat(
                    width: cardWidth,
                    icon: Icons.layers_outlined,
                    label: 'Total',
                    value: appProvider.totalProducts,
                    iconColor: _c.mutedForeground,
                    iconBgColor: _c.mutedForeground.withOpacity(0.1),
                    valueColor: _c.foreground,
                  ),
                  _BigStat(
                    width: cardWidth,
                    icon: Icons.check_circle_outline,
                    label: 'Passed',
                    value: appProvider.passedCount,
                    iconColor: _c.success,
                    iconBgColor: _c.success.withOpacity(0.1),
                    valueColor: _c.success,
                  ),
                  _BigStat(
                    width: cardWidth,
                    icon: Icons.cancel_outlined,
                    label: 'Rejected',
                    value: appProvider.rejectedCount,
                    iconColor: _c.destructive,
                    iconBgColor: _c.destructive.withOpacity(0.1),
                    valueColor: _c.destructive,
                  ),
                  _BigStat(
                    width: cardWidth,
                    icon: Icons.star_outline,
                    label: 'Flawless',
                    value: (appProvider.passedCount - 2).clamp(0, 9999), // Mock logic from original
                    iconColor: _c.primary,
                    iconBgColor: _c.primary.withOpacity(0.1),
                    valueColor: _c.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Most Common Defects Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _c.muted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most common defects',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _c.foreground,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        '$maxCount',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _c.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _c.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        mostCommonDefect,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: _c.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pass Rate Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _c.muted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _c.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pass rate',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _c.foreground,
                          ),
                        ),
                        Text(
                          '${(passRate * 100).round()}%',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _c.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: passRate,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF1C212B),
                        valueColor: AlwaysStoppedAnimation(_c.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final int value;
  final Color iconColor;
  final Color iconBgColor;
  final Color valueColor;

  const _BigStat({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBgColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _c.muted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 20),
          Text(
            '$value',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _c.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
