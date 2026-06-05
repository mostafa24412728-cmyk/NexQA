import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/app_provider.dart';
import '../models/paint_color.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import 'color_history_screen.dart';

// ─────────────────────────────────────────────────────────────────────
//  COLOR MIX SCREEN — مختبر مزج الدهانات الذكي
// ─────────────────────────────────────────────────────────────────────

class ColorMixScreen extends StatefulWidget {
  const ColorMixScreen({super.key});

  @override
  State<ColorMixScreen> createState() => _ColorMixScreenState();
}

class _ColorMixScreenState extends State<ColorMixScreen>
    with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _hasResult = false;
  String? _errorMsg;

  // نتائج الـ API
  String _hexCode   = '';
  int    _r = 0, _g = 0, _b = 0;
  String _colorName = '';
  String _recipeMarkdown = '';

  // ── Animations ───────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnim   = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── اختيار الصورة ────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file   = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes     = bytes;
      _hasResult      = false;
      _errorMsg       = null;
      _recipeMarkdown = '';
    });
  }

  // ── استدعاء الـ API ───────────────────────────────────────────────
  Future<void> _analyze() async {
    if (_imageBytes == null) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await ApiService.getColorRecipe(_imageBytes!);

    if (!mounted) return;

    if (result['success'] == true) {
      final color = result['color'] as Map<String, dynamic>;
      setState(() {
        _hexCode        = color['hex']     as String;
        _r              = color['r']       as int;
        _g              = color['g']       as int;
        _b              = color['b']       as int;
        _colorName      = color['name_ar'] as String;
        _recipeMarkdown = result['recipe_markdown'] as String;
        _hasResult      = true;
        _isLoading      = false;
      });

      // Save color record to AppProvider
      final paintColor = PaintColor(
        id: result['id'] ?? '#C0',
        imageBytes: _imageBytes,
        hexCode: _hexCode,
        r: _r,
        g: _g,
        b: _b,
        colorName: _colorName,
        recipeMarkdown: _recipeMarkdown,
        createdAt: DateTime.now(),
      );
      Provider.of<AppProvider>(context, listen: false).addPaintColor(paintColor);
    } else {
      setState(() {
        _errorMsg  = result['message'] as String? ?? 'حدث خطأ غير متوقع';
        _isLoading = false;
      });
    }
  }

  // ── نسخ الوصفة ───────────────────────────────────────────────────
  void _copyRecipe() {
    Clipboard.setData(ClipboardData(text: _recipeMarkdown));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم نسخ الوصفة!',
            style: GoogleFonts.cairo(fontSize: 14)),
        backgroundColor: const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── إعادة التعيين ─────────────────────────────────────────────────
  void _reset() {
    setState(() {
      _imageBytes     = null;
      _hasResult      = false;
      _errorMsg       = null;
      _recipeMarkdown = '';
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors  = themeProvider.colors;
    final isDark  = themeProvider.isDark;

    // لون الخشب الدافئ كـ accent لهذه الشاشة
    const accentColor = Color(0xFFD4A843);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // ── خلفية ديكور ─────────────────────────────────────────
          if (isDark) ...[
            _Orb(color: accentColor,          top: -80,  right: -60, opacity: 0.10),
            _Orb(color: const Color(0xFF8B4513), bottom: 80, left: -60, opacity: 0.08),
          ],

          SafeArea(
            child: Column(
              children: [
                // ── AppBar ───────────────────────────────────────
                _buildAppBar(colors, accentColor),

                // ── Body ─────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        if (!_hasResult) ...[
                          _buildPickerSection(colors, accentColor),
                          const SizedBox(height: 16),
                          if (_imageBytes != null) _buildImagePreview(colors, accentColor),
                          if (_isLoading)           _buildLoadingCard(colors, accentColor),
                          if (_errorMsg != null)    _buildErrorCard(colors),
                        ] else ...[
                          _buildColorCard(colors, accentColor),
                          const SizedBox(height: 16),
                          _buildRecipeCard(colors, accentColor),
                          const SizedBox(height: 16),
                          _buildActionButtons(colors, accentColor),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar(dynamic colors, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GlassCard(
            padding:      const EdgeInsets.all(10),
            borderRadius: 14,
            glowColor:    accent,
            onTap:        () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back_ios_new, color: colors.foreground, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مختبر الدهانات',
                style: GoogleFonts.cairo(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: colors.foreground, letterSpacing: -0.3,
                )),
              Text('استخرج اللون · اصنع الوصفة',
                style: GoogleFonts.cairo(
                  fontSize: 11, color: colors.mutedForeground,
                )),
            ],
          ),
          const Spacer(),
          GlassCard(
            padding:      const EdgeInsets.all(10),
            borderRadius: 14,
            glowColor:    accent,
            onTap:        () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ColorHistoryScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.history, color: colors.foreground, size: 18),
                const SizedBox(width: 4),
                Text(
                  'السجل',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── قسم اختيار الصورة ──────────────────────────────────────────
  Widget _buildPickerSection(dynamic colors, Color accent) {
    return GlassCard(
      padding:   const EdgeInsets.all(20),
      glowColor: accent,
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color:        accent.withOpacity(0.15),
              shape:        BoxShape.circle,
              border:       Border.all(color: accent.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(Icons.palette_outlined, color: accent, size: 34),
          ),
          const SizedBox(height: 14),
          Text('اختر صورة الخشب المراد طلاؤه',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: colors.foreground,
            )),
          const SizedBox(height: 6),
          Text('سيتم استخراج اللون المسيطر وإنشاء وصفة الخلط تلقائياً',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 12, color: colors.mutedForeground)),
          const SizedBox(height: 20),
          Row(
            children: [
              _PickerButton(
                icon:  Icons.camera_alt_outlined,
                label: 'الكاميرا',
                color: accent,
                colors: colors,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 12),
              _PickerButton(
                icon:  Icons.photo_library_outlined,
                label: 'المعرض',
                color: const Color(0xFF9C6EE8),
                colors: colors,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── معاينة الصورة + زر التحليل ──────────────────────────────────
  Widget _buildImagePreview(dynamic colors, Color accent) {
    return Column(
      children: [
        GlassCard(
          padding:   const EdgeInsets.all(12),
          glowColor: accent,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  _imageBytes!,
                  height: 220,
                  width:  double.infinity,
                  fit:    BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 16),
                  const SizedBox(width: 6),
                  Text('الصورة جاهزة للتحليل',
                    style: GoogleFonts.cairo(
                      fontSize: 13, color: const Color(0xFF00E676),
                      fontWeight: FontWeight.w600,
                    )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (!_isLoading)
          _GlowButton(
            label: '🔬  استخرج اللون وأنشئ الوصفة',
            color: accent,
            onTap: _analyze,
          ),
      ],
    );
  }

  // ── مؤشر التحميل ─────────────────────────────────────────────────
  Widget _buildLoadingCard(dynamic colors, Color accent) {
    return GlassCard(
      padding:   const EdgeInsets.all(28),
      glowColor: accent,
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.15),
                border: Border.all(color: accent.withOpacity(0.4), width: 2),
              ),
              child: const Center(child: Text('🎨', style: TextStyle(fontSize: 36))),
            ),
          ),
          const SizedBox(height: 20),
          Text('جاري تحليل الصورة…',
            style: GoogleFonts.cairo(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: colors.foreground,
            )),
          const SizedBox(height: 8),
          Text('يستخرج الذكاء الاصطناعي اللون ويُحضّر وصفة الخلط',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 13, color: colors.mutedForeground)),
          const SizedBox(height: 20),
          _ShimmerBar(color: accent, shimmerAnim: _shimmerAnim),
          const SizedBox(height: 10),
          _ShimmerBar(color: accent, shimmerAnim: _shimmerAnim, width: 0.65),
          const SizedBox(height: 10),
          _ShimmerBar(color: accent, shimmerAnim: _shimmerAnim, width: 0.80),
        ],
      ),
    );
  }

  // ── رسالة خطأ ─────────────────────────────────────────────────────
  Widget _buildErrorCard(dynamic colors) {
    return GlassCard(
      padding:   const EdgeInsets.all(20),
      glowColor: colors.destructive,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.destructive, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_errorMsg!,
              style: GoogleFonts.cairo(
                fontSize: 14, color: colors.destructive,
                fontWeight: FontWeight.w500,
              )),
          ),
        ],
      ),
    );
  }

  // ── بطاقة اللون المستخرج ─────────────────────────────────────────
  Widget _buildColorCard(dynamic colors, Color accent) {
    final extracted = Color.fromRGBO(_r, _g, _b, 1);
    return GlassCard(
      padding:   const EdgeInsets.all(20),
      glowColor: extracted,
      child: Row(
        children: [
          // مربع اللون
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        extracted,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: extracted.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اللون المستخرج',
                  style: GoogleFonts.cairo(fontSize: 12, color: colors.mutedForeground)),
                const SizedBox(height: 4),
                Text(_colorName,
                  style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _ColorBadge(label: _hexCode, color: extracted),
                    const SizedBox(width: 8),
                    _ColorBadge(
                      label: 'R:$_r G:$_g B:$_b',
                      color: colors.mutedForeground,
                      isSmall: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة الوصفة ─────────────────────────────────────────────────
  Widget _buildRecipeCard(dynamic colors, Color accent) {
    return GlassCard(
      padding:   const EdgeInsets.all(20),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('وصفة الخلط من خبير الدهانات',
                style: GoogleFonts.cairo(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: colors.foreground,
                )),
            ],
          ),
          const SizedBox(height: 16),
          // عرض Markdown بدون حزمة خارجية
          _MarkdownViewer(
            markdown: _recipeMarkdown,
            colors: colors,
            accent: accent,
          ),
        ],
      ),
    );
  }

  // ── أزرار الإجراءات ───────────────────────────────────────────────
  Widget _buildActionButtons(dynamic colors, Color accent) {
    return Column(
      children: [
        _GlowButton(
          label:    '📋  نسخ الوصفة الكاملة',
          color:    accent,
          onTap:    _copyRecipe,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _reset,
          child: Container(
            width: double.infinity, height: 50,
            decoration: BoxDecoration(
              color:        colors.muted,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: colors.border, width: 1),
            ),
            child: Center(
              child: Text('🔄  تحليل صورة أخرى',
                style: GoogleFonts.cairo(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: colors.mutedForeground,
                )),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final Color color;
  final double? top, left, right, bottom;
  final double opacity;
  const _Orb({required this.color, this.top, this.left, this.right, this.bottom, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: 240, height: 240,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(opacity)),
      ),
    );
  }
}

// زر اختيار الصورة
class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final dynamic colors;
  final VoidCallback onTap;
  const _PickerButton({required this.icon, required this.label, required this.color, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.35), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// زر متوهج رئيسي
class _GlowButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _GlowButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Text(label,
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
        ),
      ),
    );
  }
}

// شريط shimmer أثناء التحميل
class _ShimmerBar extends StatelessWidget {
  final Color color;
  final Animation<double> shimmerAnim;
  final double width;
  const _ShimmerBar({required this.color, required this.shimmerAnim, this.width = 1.0});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerAnim,
      builder: (_, __) {
        return Container(
          height: 12,
          width: MediaQuery.of(context).size.width * width * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment(shimmerAnim.value - 1, 0),
              end: Alignment(shimmerAnim.value + 1, 0),
              colors: [color.withOpacity(0.1), color.withOpacity(0.4), color.withOpacity(0.1)],
            ),
          ),
        );
      },
    );
  }
}

// بادج اللون
class _ColorBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSmall;
  const _ColorBadge({required this.label, required this.color, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isSmall ? 0.08 : 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(label,
        style: GoogleFonts.robotoMono(
          fontSize: isSmall ? 9 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  MARKDOWN VIEWER — عرض وصفة بدون حزمة خارجية
// ─────────────────────────────────────────────────────────────────────

class _MarkdownViewer extends StatelessWidget {
  final String markdown;
  final dynamic colors;
  final Color accent;
  const _MarkdownViewer({required this.markdown, required this.colors, required this.accent});

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

      // ### Heading
      if (line.startsWith('### ')) {
        widgets.add(_HeadingWidget(text: line.substring(4), accent: accent, colors: colors));
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // ## Heading
      if (line.startsWith('## ')) {
        widgets.add(_HeadingWidget(text: line.substring(3), accent: accent, colors: colors, large: true));
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // - bullet point
      if (line.startsWith('- ') || line.startsWith('• ')) {
        widgets.add(_BulletWidget(text: line.substring(2), colors: colors, accent: accent));
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // 1. 2. 3. numbered
      final numMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
      if (numMatch != null) {
        widgets.add(_NumberedWidget(
          number: numMatch.group(1)!,
          text:   numMatch.group(2)!,
          colors: colors,
          accent: accent,
        ));
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // *(italic note)*
      if (line.startsWith('*(') && line.endsWith(')*')) {
        widgets.add(_NoteWidget(text: line.substring(2, line.length - 2), colors: colors));
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Normal text
      widgets.add(_RichLine(line: line, colors: colors));
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

class _HeadingWidget extends StatelessWidget {
  final String text;
  final Color accent;
  final dynamic colors;
  final bool large;
  const _HeadingWidget({required this.text, required this.accent, required this.colors, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.cairo(
          fontSize: large ? 16 : 14,
          fontWeight: FontWeight.w700,
          color: colors.foreground,
        ),
      ),
    );
  }
}

class _BulletWidget extends StatelessWidget {
  final String text;
  final dynamic colors;
  final Color accent;
  const _BulletWidget({required this.text, required this.colors, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, left: 8),
          width: 6, height: 6,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        Expanded(child: _RichLine(line: text, colors: colors)),
      ],
    );
  }
}

class _NumberedWidget extends StatelessWidget {
  final String number;
  final String text;
  final dynamic colors;
  final Color accent;
  const _NumberedWidget({required this.number, required this.text, required this.colors, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withOpacity(0.4), width: 1),
          ),
          child: Center(
            child: Text(number,
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
          ),
        ),
        Expanded(child: _RichLine(line: text, colors: colors)),
      ],
    );
  }
}

class _NoteWidget extends StatelessWidget {
  final String text;
  final dynamic colors;
  const _NoteWidget({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '📝 $text',
        textDirection: TextDirection.rtl,
        style: GoogleFonts.cairo(fontSize: 11, color: colors.mutedForeground, fontStyle: FontStyle.italic),
      ),
    );
  }
}

// Rich text لمعالجة **bold** inline
class _RichLine extends StatelessWidget {
  final String line;
  final dynamic colors;
  const _RichLine({required this.line, required this.colors});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    // أزل - البادئة إن وُجدت
    String text = line.startsWith('- ') ? line.substring(2) : line;

    // معالجة **bold** و  *italic*
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(
          text: text.substring(last, m.start),
          style: GoogleFonts.cairo(fontSize: 13, color: colors.foreground),
        ));
      }
      if (m.group(1) != null) {
        // bold
        spans.add(TextSpan(
          text: m.group(1),
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: colors.foreground),
        ));
      } else if (m.group(2) != null) {
        // italic
        spans.add(TextSpan(
          text: m.group(2),
          style: GoogleFonts.cairo(fontSize: 13, fontStyle: FontStyle.italic, color: colors.mutedForeground),
        ));
      }
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(
        text: text.substring(last),
        style: GoogleFonts.cairo(fontSize: 13, color: colors.foreground),
      ));
    }

    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }
}
