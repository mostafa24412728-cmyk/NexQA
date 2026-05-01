import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'camera_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNewInspection() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CameraScreen(
            imagePath: photo.path,
            imageBytes: bytes,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final appProvider = context.watch<AppProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          if (isDark) ...[
            _Orb(color: colors.glowCyan, top: -80, left: -60, opacity: 0.12),
            _Orb(color: colors.glowPurple, top: 200, right: -80, opacity: 0.1),
            _Orb(
              color: colors.glowPink,
              bottom: 100,
              left: -40,
              opacity: 0.08,
              size: 200,
            ),
          ],
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _Header(colors: colors),
                      const SizedBox(height: 20),
                      _StatsRow(
                        colors: colors,
                        isDark: isDark,
                        total: appProvider.totalProducts,
                        passed: appProvider.passedCount,
                        rejected: appProvider.rejectedCount,
                      ),
                      const SizedBox(height: 16),
                      _Grid(
                        colors: colors,
                        isDark: isDark,
                        onNewInspection: _handleNewInspection,
                        onDashboard: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        ),
                        onPassed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const HistoryScreen(type: 'passed'),
                          ),
                        ),
                        onRejected: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const HistoryScreen(type: 'rejected'),
                          ),
                        ),
                        onSettings: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double opacity;
  final double size;

  const _Orb({
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.opacity,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppColors colors;
  const _Header({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Quality Assurance',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.mutedForeground,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'NexQA',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colors.foreground,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        GlassCard(
          padding: const EdgeInsets.all(10),
          glowColor: colors.glowCyan,
          borderRadius: 14,
          child: Icon(Icons.qr_code_scanner, color: colors.glowCyan, size: 22),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final int total;
  final int passed;
  final int rejected;

  const _StatsRow({
    required this.colors,
    required this.isDark,
    required this.total,
    required this.passed,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Total Products',
          value: total,
          color: colors.glowCyan,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Passed',
          value: passed,
          color: colors.success,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Rejected',
          value: rejected,
          color: colors.destructive,
          colors: colors,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final AppColors colors;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        glowColor: color,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -1,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final VoidCallback onNewInspection;
  final VoidCallback onDashboard;
  final VoidCallback onPassed;
  final VoidCallback onRejected;
  final VoidCallback onSettings;

  const _Grid({
    required this.colors,
    required this.isDark,
    required this.onNewInspection,
    required this.onDashboard,
    required this.onPassed,
    required this.onRejected,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 12) / 2;

    return Column(
      children: [
        Row(
          children: [
            _GridCard(
              width: cardWidth,
              icon: Icons.camera_alt,
              label: 'New Inspection',
              color: colors.glowCyan,
              colors: colors,
              isDark: isDark,
              onTap: onNewInspection,
            ),
            const SizedBox(width: 12),
            _GridCard(
              width: cardWidth,
              icon: Icons.bar_chart,
              label: 'Dashboard',
              color: colors.glowPurple,
              colors: colors,
              isDark: isDark,
              onTap: onDashboard,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _GridCard(
              width: cardWidth,
              icon: Icons.check_circle,
              label: 'Passed Products',
              color: colors.success,
              colors: colors,
              isDark: isDark,
              onTap: onPassed,
            ),
            const SizedBox(width: 12),
            _GridCard(
              width: cardWidth,
              icon: Icons.cancel,
              label: 'Rejected Products',
              color: colors.destructive,
              colors: colors,
              isDark: isDark,
              onTap: onRejected,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: _GridCard(
            width: cardWidth,
            icon: Icons.settings,
            label: 'Settings',
            color: colors.glowPink,
            colors: colors,
            isDark: isDark,
            onTap: onSettings,
            centerContent: true,
          ),
        ),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final Color color;
  final AppColors colors;
  final bool isDark;
  final VoidCallback onTap;
  final bool centerContent;

  const _GridCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
    required this.isDark,
    required this.onTap,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: width,
      height: 180,
      padding: const EdgeInsets.all(24),
      glowColor: color,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.foreground,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
