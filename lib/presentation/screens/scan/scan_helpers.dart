import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phss_calculator.dart';
import '../../../data/models/product_model.dart';

String labelKey(SuitabilityLabel l) {
  switch (l) {
    case SuitabilityLabel.safe:
      return 'safe';
    case SuitabilityLabel.caution:
      return 'caution';
    case SuitabilityLabel.avoid:
      return 'avoid';
    case SuitabilityLabel.unverified:
      return 'unverified';
  }
}

/// One-line verdict shown under the score.
String verdictMessage(SuitabilityLabel l) {
  switch (l) {
    case SuitabilityLabel.safe:
      return 'This product is generally safe to consume.';
    case SuitabilityLabel.caution:
      return 'Okay in moderation — some details don\'t match your profile.';
    case SuitabilityLabel.avoid:
      return 'This product conflicts with your health profile.';
    case SuitabilityLabel.unverified:
      return 'We couldn\'t check this product against your profile.';
  }
}

/// Short sentence for the "Health Impact" section.
String impactMessage(SuitabilityLabel l) {
  switch (l) {
    case SuitabilityLabel.safe:
      return 'Generally safe for most people.';
    case SuitabilityLabel.caution:
      return 'Fine occasionally — review the notes above.';
    case SuitabilityLabel.avoid:
      return 'Not recommended for your health profile.';
    case SuitabilityLabel.unverified:
      return 'Not enough data to assess the health impact.';
  }
}

double? asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

class Highlight {
  final String label;
  final Color color;
  final IconData icon;
  const Highlight(this.label, this.color, this.icon);
}

/// Quick facts shown as chips under the score.
List<Highlight> buildHighlights(ProductModel product, PhssResult phss) {
  final out = <Highlight>[];
  if (phss.isUnverified) return out;

  if (phss.hasAllergenConflict) {
    out.add(const Highlight(
        'Allergen alert', AppColors.avoid, Icons.warning_amber_rounded));
  } else {
    out.add(const Highlight(
        'No allergen conflicts', AppColors.safe, Icons.check_circle_rounded));
  }

  for (final a in product.allergenStatements.take(3)) {
    out.add(Highlight('Contains $a', AppColors.caution, Icons.info_rounded));
  }

  final n = product.nutritionPer100g;
  final sodium = asNum(n['sodium_mg']);
  if (sodium != null) {
    if (sodium <= 120) {
      out.add(const Highlight('Low sodium', AppColors.safe, Icons.check_circle_rounded));
    } else if (sodium > 600) {
      out.add(const Highlight('High sodium', AppColors.caution, Icons.error_rounded));
    }
  }
  final sugar = asNum(n['sugars_g']);
  if (sugar != null) {
    if (sugar <= 5) {
      out.add(const Highlight('Low sugar', AppColors.safe, Icons.check_circle_rounded));
    } else if (sugar > 15) {
      out.add(const Highlight('High sugar', AppColors.caution, Icons.error_rounded));
    }
  }
  final sat = asNum(n['saturated_fat_g']);
  if (sat != null && sat > 5) {
    out.add(const Highlight('High saturated fat', AppColors.caution, Icons.error_rounded));
  }
  return out;
}

String formatNutritionKey(String key) {
  return key
      .replaceAll('_g', ' (g)')
      .replaceAll('_mg', ' (mg)')
      .replaceAll('_kcal', ' (kcal)')
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String formatNutritionValue(dynamic value) {
  final v = asNum(value);
  if (v == null) return '-';
  return v.toStringAsFixed(1);
}
