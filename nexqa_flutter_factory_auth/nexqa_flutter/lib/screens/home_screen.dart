import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'camera_screen.dart';
import 'color_mix_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> _handleNewInspection({required ImageSource source}) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
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
    final _c = context.watch<ThemeProvider>().colors;
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: _c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 32),
              
              const _SectionTitle('OVERVIEW'),
              const SizedBox(height: 12),
              _OverviewCard(
                total: appProvider.totalProducts,
                passed: appProvider.passedCount,
                rejected: appProvider.rejectedCount,
              ),
              const SizedBox(height: 28),

              const _SectionTitle('INSPECT'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GridCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      subtitle: 'New inspection',
                      iconColor: _c.primary,
                      onTap: () => _handleNewInspection(source: ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GridCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Gallery',
                      subtitle: 'From your library',
                      iconColor: _c.primary,
                      onTap: () => _handleNewInspection(source: ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const _SectionTitle('RESULTS'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GridCard(
                      icon: Icons.check_circle_outline,
                      title: 'Passed',
                      subtitle: 'Meets the standard',
                      iconColor: _c.success,
                      badgeCount: appProvider.passedCount,
                      badgeColor: _c.success,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen(type: 'passed')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GridCard(
                      icon: Icons.cancel_outlined,
                      title: 'Rejected',
                      subtitle: 'Needs another look',
                      iconColor: _c.destructive,
                      badgeCount: appProvider.rejectedCount,
                      badgeColor: _c.destructive,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen(type: 'rejected')),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const _SectionTitle('MANAGE'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GridCard(
                      icon: Icons.bar_chart_outlined,
                      title: 'Dashboard',
                      subtitle: 'Trends and history',
                      iconColor: _c.mutedForeground,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GridCard(
                      icon: Icons.tune_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      iconColor: _c.mutedForeground,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              _PaintLabCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ColorMixScreen()),
                ),
              ),
              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleNewInspection(source: ImageSource.camera),
        backgroundColor: _c.primary,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: _c.border, width: 1)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: _c.background,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: _c.primary,
            unselectedItemColor: _c.mutedForeground,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            elevation: 0,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 1) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardScreen()));
              } else if (index == 3) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen(type: 'rejected')));
              } else if (index == 4) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 24), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined, size: 24), label: 'Reports'),
              BottomNavigationBarItem(icon: Icon(Icons.camera, color: Colors.transparent, size: 24), label: ''), // Spacer for FAB
              BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline, size: 24), label: 'Review'),
              BottomNavigationBarItem(icon: Icon(Icons.tune_outlined, size: 24), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI QUALITY ASSURANCE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _c.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'NexQA',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _c.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _c.muted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _c.border),
                  ),
                  child: Text(
                    'v2.1',
                    style: GoogleFonts.inter(fontSize: 10, color: _c.mutedForeground, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Automated color and finish inspection.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _c.mutedForeground,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _c.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _c.border),
          ),
          child: Icon(Icons.qr_code_scanner, color: _c.mutedForeground, size: 20),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _c.mutedForeground,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final int total;
  final int passed;
  final int rejected;

  const _OverviewCard({required this.total, required this.passed, required this.rejected});

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: _c.muted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _OverviewStat('Total', total, _c.primary),
          Container(width: 1, height: 30, color: _c.border),
          _OverviewStat('Passed', passed, _c.success),
          Container(width: 1, height: 30, color: _c.border),
          _OverviewStat('Rejected', rejected, _c.destructive),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _OverviewStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _c.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? badgeColor;

  const _GridCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.badgeCount,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _c.muted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _c.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _c.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: badgeColor!.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _c.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _c.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaintLabCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PaintLabCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final _c = context.watch<ThemeProvider>().colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _c.muted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Row(
          children: [
            // overlapping circles icon
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 10,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFBBF24).withOpacity(0.8)),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF87171).withOpacity(0.8)),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF34D399).withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مختبر مزج الدهانات',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                  Text(
                    'استخرج اللون وأنشئ وصفة الخلط بالذكاء الاصطناعي',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: _c.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _c.mutedForeground, size: 20),
          ],
        ),
      ),
    );
  }
}
