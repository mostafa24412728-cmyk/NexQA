import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

class ResultScreen extends StatelessWidget {
  final Product product;
  const ResultScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isPassed = product.status == 'passed';
    final isError = product.status == 'error';
    final statusColor = isPassed 
        ? colors.success 
        : (isError ? Colors.orange : colors.destructive);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 14,
                        glowColor: statusColor,
                        onTap: () {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        child: Icon(Icons.home, color: colors.foreground, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        'Result ${product.id}',
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
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withOpacity(0.15),
                      border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
                    ),
                    child: Icon(
                      isPassed ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isPassed ? 'PASSED' : (isError ? 'ERROR' : 'REJECTED'),
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPassed
                        ? 'Product meets quality standards'
                        : (isError 
                            ? 'Connection to AI model failed'
                            : 'Defects detected — product rejected'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    glowColor: statusColor,
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.analytics_outlined,
                          label: 'AI Confidence',
                          value: '${product.confidence.toStringAsFixed(1)}%',
                          colors: colors,
                          valueColor: statusColor,
                        ),
                        _Divider(color: colors.border),
                        _Row(
                          icon: Icons.bug_report_outlined,
                          label: 'Defect Type',
                          value: product.defectType,
                          colors: colors,
                        ),
                        _Divider(color: colors.border),
                        _Row(
                          icon: Icons.business_outlined,
                          label: 'Buyer',
                          value: product.buyer,
                          colors: colors,
                        ),
                        _Divider(color: colors.border),
                        _Row(
                          icon: Icons.local_shipping_outlined,
                          label: 'Shipping',
                          value: product.shippingCompany,
                          colors: colors,
                        ),
                        _Divider(color: colors.border),
                        _Row(
                          icon: Icons.access_time_outlined,
                          label: 'Inspected',
                          value: _formatDate(product.inspectedAt),
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (product.defectDescription != null || product.defectImpact != null) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      glowColor: Colors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '🤖 تقرير Gemini AI',
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: colors.foreground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (product.defectDescription != null) ...[
                            Text(
                              'التشخيص:',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.defectDescription!,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: colors.foreground,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (product.defectImpact != null) ...[
                            Text(
                              '⚠️ ماذا سيحدث لو استخدمت هذه الخشبة؟',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.defectImpact!,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: colors.foreground,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? (product.imageBytes != null
                            ? Image.memory(
                                product.imageBytes!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey[900],
                                child: const Icon(Icons.image_not_supported,
                                    size: 40),
                              ))
                        : Image.file(
                            File(product.imagePath),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
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

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final dynamic colors;
  final Color? valueColor;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: c.mutedForeground, size: 16),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: c.mutedForeground),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? c.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: color);
  }
}
