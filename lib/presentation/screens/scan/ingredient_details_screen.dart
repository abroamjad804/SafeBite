import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phss_calculator.dart';
import '../../../data/providers/scan_provider.dart';
import '../../widgets/common/fx.dart';
import 'scan_helpers.dart';

/// Second step after a scan: ingredients, flags, health impact and nutrition.
class IngredientDetailsScreen extends StatelessWidget {
  const IngredientDetailsScreen({super.key});

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
    final statusText = phss.label == SuitabilityLabel.safe
        ? 'Safe'
        : PhssCalculator.labelText(phss.label);
    final ingredientNames = product.ingredients
        .map((i) => i.name.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    final nutrition =
        product.nutritionPer100g.entries.where((e) => e.value != null).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: 'Ingredient Details',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RaisedCard(
                        radius: 24,
                        child: Row(
                          children: [
                            ProductThumb(
                                name: product.name,
                                size: 68,
                                imageUrl: product.imageUrl),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink)),
                                  if (product.brand != null)
                                    Text(product.brand!,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary)),
                                  const SizedBox(height: 6),
                                  Text(product.dataSource.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: StatusBadge(
                          text: statusText,
                          color: style.color,
                          icon: style.icon,
                          large: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const SectionTitle('Ingredients'),
                      const SizedBox(height: 10),
                      RaisedCard(
                        radius: 20,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            ingredientNames.isEmpty
                                ? 'Ingredient list not available for this product.'
                                : ingredientNames.join(', '),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                height: 1.5),
                          ),
                        ),
                      ),

                      if (phss.warnings.isNotEmpty || phss.reasons.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const SectionTitle('What we found'),
                        const SizedBox(height: 10),
                        ...phss.warnings.map((w) => _Flag(
                              text: w.replaceAll('⚠️', '').trim(),
                              color: AppColors.avoid,
                              background: AppColors.blush,
                              icon: Icons.error_rounded,
                            )),
                        ...phss.reasons.map((r) => _Flag(
                              text: r,
                              color: AppColors.caution,
                              background: AppColors.cream,
                              icon: Icons.info_rounded,
                            )),
                      ],

                      const SizedBox(height: 22),
                      const SectionTitle('Health Impact'),
                      const SizedBox(height: 10),
                      RaisedCard(
                        radius: 20,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(impactMessage(phss.label),
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink)),
                              if (!phss.isUnverified) ...[
                                const SizedBox(height: 4),
                                Text(
                                    'Suitability score: ${phss.score.toStringAsFixed(0)}/100',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)),
                              ],
                            ],
                          ),
                        ),
                      ),

                      if (nutrition.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const SectionTitle('Nutrition (per 100g)'),
                        const SizedBox(height: 10),
                        RaisedCard(
                          radius: 20,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            children: [
                              for (int i = 0; i < nutrition.length; i++)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                  decoration: BoxDecoration(
                                    border: i < nutrition.length - 1
                                        ? const Border(
                                            bottom: BorderSide(
                                                color: AppColors.divider))
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(formatNutritionKey(nutrition[i].key),
                                          style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary)),
                                      Text(formatNutritionValue(nutrition[i].value),
                                          style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.ink)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 26),
                      GradientButton(
                        label: 'Save & Back to Home',
                        icon: Icons.home_rounded,
                        onPressed: () {
                          scan.saveCurrentScan();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved to history')),
                          );
                          context.go('/home');
                          scan.clearCurrentScan();
                        },
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

class _Flag extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final IconData icon;
  const _Flag({
    required this.text,
    required this.color,
    required this.background,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.35)),
          ),
        ],
      ),
    );
  }
}
