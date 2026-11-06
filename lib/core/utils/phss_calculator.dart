import '../../data/models/user_profile_model.dart';
import '../../data/models/product_model.dart';

enum SuitabilityLabel { safe, caution, avoid, unverified }

class PhssResult {
  final double score;
  final SuitabilityLabel label;
  final List<String> warnings;
  final List<String> reasons;
  final bool hasAllergenConflict;
  final bool isUnverified;

  PhssResult({
    required this.score,
    required this.label,
    required this.warnings,
    required this.reasons,
    this.hasAllergenConflict = false,
    this.isUnverified = false,
  });
}

class PhssCalculator {
  /// Calculates the Personal Health Suitability Score
  /// PHSS(H, N, D, G) = 0.40H + 0.30N + 0.20D + 0.10G
  static PhssResult calculate(UserProfile profile, ProductModel product) {
    final warnings = <String>[];
    final reasons = <String>[];
    bool hasAllergenConflict = false;

    // ── Hard constraint: allergen check ─────────────────────────────────────
    final ingredientNames = product.ingredients
        .map((i) => i.name.toLowerCase())
        .toList();

    for (final allergen in profile.allergies) {
      final a = allergen.toLowerCase();
      final found = ingredientNames.any((ing) => ing.contains(a));
      if (found) {
        hasAllergenConflict = true;
        warnings.add('ALLERGEN: $allergen detected in ingredients');
      }
    }

    // If allergen conflict → immediate Avoid, skip scoring
    if (hasAllergenConflict) {
      return PhssResult(
        score: 0,
        label: SuitabilityLabel.avoid,
        warnings: warnings,
        reasons: ['Product contains a declared allergen — marked Avoid'],
        hasAllergenConflict: true,
      );
    }

    // ── Avoid list check ────────────────────────────────────────────────────
    for (final avoided in profile.avoidList) {
      final a = avoided.toLowerCase();
      final found = ingredientNames.any((ing) => ing.contains(a));
      if (found) {
        warnings.add('Avoid list match: $avoided found');
      }
    }

    // ── H: Health-related dietary needs (40%) ───────────────────────────────
    double h = 100.0;
    final nutrition = product.nutritionPer100g;

    if (profile.dietaryNeeds.contains('low_sodium') ||
        profile.dietaryNeeds.contains('Low Sodium')) {
      final sodium = nutrition['sodium_mg'] ?? nutrition['sodium'];
      if (sodium != null) {
        if (sodium > 600) {
          h -= 40;
          reasons.add('High sodium (${sodium}mg per 100g)');
        } else if (sodium > 300) {
          h -= 20;
          reasons.add('Moderate sodium (${sodium}mg per 100g)');
        }
      }
    }

    if (profile.dietaryNeeds.contains('low_saturated_fat') ||
        profile.dietaryNeeds.contains('Low Saturated Fat')) {
      final satFat = nutrition['saturated_fat_g'] ?? nutrition['saturated-fat'];
      if (satFat != null) {
        if (satFat > 5) {
          h -= 30;
          reasons.add('High saturated fat (${satFat}g per 100g)');
        } else if (satFat > 2) {
          h -= 10;
          reasons.add('Moderate saturated fat (${satFat}g per 100g)');
        }
      }
    }

    h = h.clamp(0, 100);

    // ── N: Nutrition goals (30%) ─────────────────────────────────────────────
    double n = 100.0;

    if (profile.nutritionGoals.contains('reduce_sugar') ||
        profile.nutritionGoals.contains('Reduce Sugar')) {
      final sugar = nutrition['sugars_g'] ?? nutrition['sugars'];
      if (sugar != null) {
        if (sugar > 20) {
          n -= 40;
          reasons.add('High sugar content (${sugar}g per 100g)');
        } else if (sugar > 10) {
          n -= 20;
          reasons.add('Moderate sugar content (${sugar}g per 100g)');
        }
      }
    }

    if (profile.nutritionGoals.contains('reduce_calories') ||
        profile.nutritionGoals.contains('Reduce Calories')) {
      final kcal = nutrition['energy_kcal'] ?? nutrition['energy-kcal'];
      if (kcal != null) {
        if (kcal > 400) {
          n -= 30;
          reasons.add('High calorie content (${kcal} kcal per 100g)');
        }
      }
    }

    n = n.clamp(0, 100);

    // ── D: Dietary preferences (20%) ────────────────────────────────────────
    double d = 100.0;

    if (profile.dietaryPreferences.contains('vegetarian') ||
        profile.dietaryPreferences.contains('Vegetarian')) {
      final meatIngredients = ['chicken', 'beef', 'pork', 'fish', 'meat', 'gelatin', 'lard'];
      for (final meat in meatIngredients) {
        if (ingredientNames.any((ing) => ing.contains(meat))) {
          d -= 60;
          reasons.add('Contains non-vegetarian ingredient: $meat');
          break;
        }
      }
    }

    if (profile.dietaryPreferences.contains('vegan') ||
        profile.dietaryPreferences.contains('Vegan')) {
      final animalIngredients = ['milk', 'egg', 'honey', 'butter', 'cream', 'cheese', 'whey', 'casein'];
      for (final animal in animalIngredients) {
        if (ingredientNames.any((ing) => ing.contains(animal))) {
          d -= 40;
          reasons.add('Contains animal-derived ingredient: $animal');
          break;
        }
      }
    }

    d = d.clamp(0, 100);

    // ── G: General ingredient suitability (10%) ──────────────────────────────
    double g = 100.0;
    final knownBadAdditives = ['e621', 'msg', 'sodium nitrate', 'bha', 'bht', 'tbhq', 'carrageenan'];
    for (final additive in knownBadAdditives) {
      if (ingredientNames.any((ing) => ing.contains(additive))) {
        g -= 25;
        reasons.add('Contains additive of concern: $additive');
      }
    }
    g = g.clamp(0, 100);

    // ── Final PHSS ───────────────────────────────────────────────────────────
    final score = (0.40 * h) + (0.30 * n) + (0.20 * d) + (0.10 * g);

    SuitabilityLabel label;
    if (score >= 80) {
      label = SuitabilityLabel.safe;
    } else if (score >= 50) {
      label = SuitabilityLabel.caution;
    } else {
      label = SuitabilityLabel.avoid;
    }

    return PhssResult(
      score: score,
      label: label,
      warnings: warnings,
      reasons: reasons,
    );
  }

  static String labelText(SuitabilityLabel label) {
    switch (label) {
      case SuitabilityLabel.safe:
        return 'Safe*';
      case SuitabilityLabel.caution:
        return 'Caution';
      case SuitabilityLabel.avoid:
        return 'Avoid';
      case SuitabilityLabel.unverified:
        return 'Unverified';
    }
  }
}
