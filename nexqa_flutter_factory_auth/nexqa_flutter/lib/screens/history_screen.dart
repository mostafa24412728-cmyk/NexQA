import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  final String type;
  const HistoryScreen({super.key, required this.type});

  bool get isPassed => type == 'passed';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final appProvider = context.watch<AppProvider>();
    final colors = themeProvider.colors;
    final statusColor = isPassed ? colors.success : colors.destructive;
    final products =
        isPassed ? appProvider.passedProducts : appProvider.rejectedProducts;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    glowColor: statusColor,
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back,
                        color: colors.foreground, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    isPassed ? 'Passed Products' : 'Rejected Products',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${products.length}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPassed ? Icons.check_circle : Icons.cancel,
                            color: statusColor.withOpacity(0.4),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${isPassed ? 'passed' : 'rejected'} products yet',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _ProductTile(product: products[i], colors: colors),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final dynamic colors;

  const _ProductTile({required this.product, required this.colors});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    final isPassed = product.status == 'passed';
    final statusColor = isPassed ? c.success : c.destructive;

    return GlassCard(
      glowColor: statusColor,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? (product.imageBytes != null
                    ? Image.memory(
                        product.imageBytes!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: colors.muted,
                        child: const Icon(Icons.image_not_supported),
                      ))
                : Image.file(
                    File(product.imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.confidence.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.defectType,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.buyer} · ${product.shippingCompany}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
