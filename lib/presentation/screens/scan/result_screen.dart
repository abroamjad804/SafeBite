import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phss_calculator.dart';
import '../../../data/providers/scan_provider.dart';
import '../../widgets/common/fx.dart';
import 'scan_helpers.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final product = scan.currentProduct;
    final phss = scan.currentPhss;

    if (product == null || phss == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final style = StatusStyle.of(labelKey(phss.label));
    final color = style.color;
    final statusText = phss.label == SuitabilityLabel.safe
        ? 'Safe'
        : PhssCalculator.labelText(phss.label);
    final highlights = buildHighlights(product, phss);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: 'Scan Result',
                onBack: () {
                  scan.clearCurrentScan();
                  context.pop();
                },
                action: IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.ink),
                  onPressed: () {
                    scan.saveCurrentScan();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved to history'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(product.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink)),
                            if (product.brand != null)
                              Text(product.brand!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary)),
                            const SizedBox(height: 18),
                            if (!phss.isUnverified)
                              ScoreRing(
                                value: phss.score,
                                color: color,
                                size: 190,
                                stroke: 14,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(phss.score.toStringAsFixed(0),
                                        style: TextStyle(
                                            fontSize: 62,
                                            fontWeight: FontWeight.w900,
                                            height: 1,
                                            color: color)),
                                    const Text('/100',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              )
                            else
                              IconBadge(icon: style.icon, color: color, size: 110),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Leaf(size: 34, angle: -0.7, color: AppColors.mint),
                                const SizedBox(width: 10),
                                StatusBadge(
                                    text: statusText, color: color, icon: style.icon),
                                const SizedBox(width: 10),
                                Leaf(size: 42, angle: 0.5, color: AppColors.primary.withValues(alpha: 0.7)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(verdictMessage(phss.label),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    height: 1.4)),
                            if (!phss.isUnverified) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'Safe means no conflict detected — not a medical guarantee.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (highlights.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const SectionTitle('Ingredient Highlights'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: highlights
                              .map((h) => InfoChip(
                                  label: h.label, color: h.color, icon: h.icon))
                              .toList(),
                        ),
                      ],
                      if (phss.warnings.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const SectionTitle('Warnings'),
                        const SizedBox(height: 10),
                        ...phss.warnings.map(
                          (w) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.blush,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_rounded,
                                    color: AppColors.avoid, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(w.replaceAll('⚠️', '').trim(),
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      GradientButton(
                        label: 'View Details',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push('/details'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
