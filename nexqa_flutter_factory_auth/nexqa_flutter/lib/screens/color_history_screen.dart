import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';
import 'package:flutter/services.dart';

class ColorHistoryScreen extends StatefulWidget {
  const ColorHistoryScreen({super.key});

  @override
  State<ColorHistoryScreen> createState() => _ColorHistoryScreenState();
}

class _ColorHistoryScreenState extends State<ColorHistoryScreen> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _syncFromServer();
  }

  Future<void> _syncFromServer() async {
    setState(() => _syncing = true);
    await context.read<AppProvider>().syncColorsFromServer();
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final appProvider = context.watch<AppProvider>();
    final colors = themeProvider.colors;
    const accentColor = Color(0xFFD4A843);
    final paintColors = appProvider.paintColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    glowColor: accentColor,
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: colors.foreground, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    'سجل الدهانات والألوان',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
                  ),
                  const Spacer(),
                   // Badge count + sync indicator
                  if (_syncing)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFD4A843),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _syncFromServer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${paintColors.length}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.refresh, size: 14, color: accentColor),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── List ─────────────────────────────────────────
            Expanded(
              child: paintColors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            color: accentColor.withOpacity(0.4),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد ألوان محفوظة بعد',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: paintColors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = paintColors[i];
                        final rgbColor = Color.fromRGBO(item.r, item.g, item.b, 1);
                        return GlassCard(
                          glowColor: rgbColor,
                          padding: const EdgeInsets.all(14),
                          onTap: () => _showRecipeDetails(context, item, colors, rgbColor),
                          child: Row(
                            children: [
                              // Color Preview Circle
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: rgbColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: rgbColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.colorName,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: colors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: rgbColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.hexCode,
                                            style: GoogleFonts.robotoMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: rgbColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'R:${item.r} G:${item.g} B:${item.b}',
                                          style: GoogleFonts.robotoMono(
                                            fontSize: 10,
                                            color: colors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: colors.mutedForeground,
                                size: 14,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, dynamic item, dynamic colors, Color rgbColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: rgbColor.withOpacity(0.3), width: 1.5),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.mutedForeground.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: rgbColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.colorName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colors.foreground,
                                    ),
                                  ),
                                  Text(
                                    item.hexCode,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 12,
                                      color: rgbColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Text(
                          '🧪 وصفة الخلط:',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SimpleMarkdownRenderer(
                          markdown: item.recipeMarkdown,
                          colors: colors,
                          accent: rgbColor,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rgbColor,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.recipeMarkdown));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ تم نسخ الوصفة!',
                                style: GoogleFonts.cairo(fontSize: 14)),
                            backgroundColor: const Color(0xFF00E676),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(
                        'نسخ الوصفة الكاملة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SimpleMarkdownRenderer extends StatelessWidget {
  final String markdown;
  final dynamic colors;
  final Color accent;
  const _SimpleMarkdownRenderer({required this.markdown, required this.colors, required this.accent});

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('### ')) {
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border(left: BorderSide(color: accent, width: 3)),
          ),
          child: Text(line.substring(4),
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: colors.foreground)),
        ));
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      if (line.startsWith('- ') || line.startsWith('• ')) {
        widgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, left: 8),
              width: 5, height: 5,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            Expanded(child: Text(line.substring(2), style: GoogleFonts.cairo(fontSize: 12, color: colors.foreground))),
          ],
        ));
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      final numMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
      if (numMatch != null) {
        widgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(numMatch.group(1)!,
                    style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: accent)),
              ),
            ),
            Expanded(child: Text(numMatch.group(2)!, style: GoogleFonts.cairo(fontSize: 12, color: colors.foreground))),
          ],
        ));
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      widgets.add(Text(line, style: GoogleFonts.cairo(fontSize: 12, color: colors.foreground)));
      widgets.add(const SizedBox(height: 4));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
