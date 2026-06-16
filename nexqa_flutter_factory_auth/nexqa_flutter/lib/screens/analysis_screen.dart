import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import 'result_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final String imagePath;
  final Uint8List? imageBytes;
  const AnalysisScreen({super.key, required this.imagePath, this.imageBytes});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnim;
  late Animation<double> _pulseAnim;

  int _step = 0;
  final List<String> _steps = [
    'Loading image...',
    'Pre-processing frames...',
    'Running NexQA Vision v2...',
    'Detecting defects...',
    'Generating report...',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanController);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.1).animate(_pulseController);

    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) setState(() => _step = i);
    }

    // Call API
    if (mounted) setState(() => _step = 3);
    final response = await ApiService.predict(
      widget.imagePath,
      bytes: widget.imageBytes,
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _step = 4);
    
    await Future.delayed(const Duration(milliseconds: 500));
    _finishAnalysis(response);
  }

  void _finishAnalysis(Map<String, dynamic> response) {
    if (!mounted) return;
    
    final rng = Random();
    String defectType = 'None';
    String? defectDescription;
    String? defectImpact;
    double confidence = 100.0;
    String status = 'passed';

    if (response['success'] == true) {
      final List data = response['data'];
      if (data.isNotEmpty) {
        // Find highest confidence defect
        var bestMatch = data.first;
        for (var d in data) {
          if (d['confidence'] > bestMatch['confidence']) {
            bestMatch = d;
          }
        }
        defectType = bestMatch['name'];
        defectDescription = bestMatch['description'];
        defectImpact = bestMatch['impact'];
        confidence = (bestMatch['confidence'] as num).toDouble() * 100;
        status = 'rejected';
      }
    } else {
      // If API fails, fallback to some logic or show error
      defectType = 'Error: ${response['message']}';
      status = 'error';
    }

    final buyers = [
      'Acme Corp',
      'Global Tech',
      'Nordic Industries',
      'Pacific Goods',
    ];
    final shippers = ['DHL', 'FedEx', 'UPS', 'Maersk'];

    Uint8List? finalImageBytes = widget.imageBytes;
    if (response['processed_image_base64'] != null) {
      try {
        finalImageBytes = base64Decode(response['processed_image_base64']);
      } catch (e) {
        debugPrint('Failed to decode processed image: $e');
      }
    }

    final appProvider = context.read<AppProvider>();
    final product = Product(
      id: '#${appProvider.totalProducts + 1}',
      imagePath: widget.imagePath,
      imageBytes: finalImageBytes,
      status: status,
      confidence: confidence,
      defectType: defectType,
      defectDescription: defectDescription,
      defectImpact: defectImpact,
      buyer: buyers[rng.nextInt(buyers.length)],
      shippingCompany: shippers[rng.nextInt(shippers.length)],
      inspectedAt: DateTime.now(),
    );

    context.read<AppProvider>().addProduct(product);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(product: product)),
    );
  }


  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.glowCyan.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.glowCyan.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            kIsWeb
                                ? (widget.imageBytes != null
                                    ? Image.memory(
                                        widget.imageBytes!,
                                        fit: BoxFit.cover,
                                        width: 200,
                                        height: 200,
                                      )
                                    : Container(
                                        width: 200,
                                        height: 200,
                                        color: colors.muted,
                                        child: const Icon(Icons.image_not_supported),
                                      ))
                                : Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  ),
                            AnimatedBuilder(
                              animation: _scanAnim,
                              builder: (_, __) {
                                return Positioned(
                                  top: _scanAnim.value * 200 - 2,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          colors.glowCyan.withOpacity(0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colors.glowCyan.withOpacity(0.05),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'AI Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NexQA Vision v2 is scanning your product',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: colors.glowCyan,
                    child: Column(
                      children: List.generate(
                        _steps.length,
                        (i) => _StepRow(
                          label: _steps[i],
                          state: i < _step
                              ? _StepState.done
                              : i == _step
                                  ? _StepState.active
                                  : _StepState.pending,
                          colors: colors,
                        ),
                      ),
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

enum _StepState { done, active, pending }

class _StepRow extends StatelessWidget {
  final String label;
  final _StepState state;
  final dynamic colors;

  const _StepRow({
    required this.label,
    required this.state,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    Color iconColor;
    IconData icon;
    if (state == _StepState.done) {
      iconColor = c.success;
      icon = Icons.check_circle;
    } else if (state == _StepState.active) {
      iconColor = c.glowCyan;
      icon = Icons.radio_button_checked;
    } else {
      iconColor = c.mutedForeground;
      icon = Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: state == _StepState.pending ? c.mutedForeground : c.foreground,
              fontWeight: state == _StepState.active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
