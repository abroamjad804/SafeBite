class IngredientItem {
  final String name;
  final String? canonicalName;
  final String matchStatus; // 'confirmed', 'fuzzy', 'unmatched'
  final double? confidence;
  final bool isAllergen;
  final bool isOnAvoidList;
  final String? description;

  IngredientItem({
    required this.name,
    this.canonicalName,
    this.matchStatus = 'unmatched',
    this.confidence,
    this.isAllergen = false,
    this.isOnAvoidList = false,
    this.description,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) => IngredientItem(
        name: json['name'] ?? '',
        canonicalName: json['canonical_name'],
        matchStatus: json['match_status'] ?? 'unmatched',
        confidence: json['confidence']?.toDouble(),
        isAllergen: json['is_allergen'] ?? false,
        isOnAvoidList: json['is_on_avoid_list'] ?? false,
        description: json['description'],
      );
}

class ProductModel {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final List<IngredientItem> ingredients;
  final Map<String, dynamic> nutritionPer100g;
  final List<String> allergenStatements;
  final String dataSource; // 'ocr' or legacy source
  final bool hasDiscrepancy;
  final String? discrepancyNote;
  final DateTime scannedAt;

  ProductModel({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.ingredients = const [],
    this.nutritionPer100g = const {},
    this.allergenStatements = const [],
    this.dataSource = 'ocr',
    this.hasDiscrepancy = false,
    this.discrepancyNote,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  factory ProductModel.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] ?? json;
    final nutriments = product['nutriments'] ?? {};
    final ingredientsJson =
        product['ingredients'] as List<dynamic>? ?? [];

    return ProductModel(
      barcode: product['code'] ?? product['_id'] ?? '',
      name: product['product_name'] ??
          product['product_name_en'] ??
          'Unknown Product',
      brand: product['brands'],
      imageUrl: product['image_url'] ?? product['image_front_url'],
      ingredients: ingredientsJson
          .map((i) => IngredientItem(
                name: (i['text'] ?? i['id'] ?? '').toString(),
                matchStatus: 'confirmed',
              ))
          .toList(),
      nutritionPer100g: {
        'energy_kcal': nutriments['energy-kcal_100g'],
        'fat_g': nutriments['fat_100g'],
        'saturated_fat_g': nutriments['saturated-fat_100g'],
        'carbohydrates_g': nutriments['carbohydrates_100g'],
        'sugars_g': nutriments['sugars_100g'],
        'fiber_g': nutriments['fiber_100g'],
        'proteins_g': nutriments['proteins_100g'],
        'sodium_mg': nutriments['sodium_100g'] != null
            ? (nutriments['sodium_100g'] * 1000).toDouble()
            : null,
        'salt_g': nutriments['salt_100g'],
      },
      allergenStatements:
          (product['allergens_tags'] as List<dynamic>? ?? [])
              .map((a) => a.toString().replaceAll('en:', ''))
              .toList(),
      dataSource: 'barcode',
    );
  }

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'brand': brand,
        'imageUrl': imageUrl,
        'ingredients': ingredients.map((i) => {'name': i.name}).toList(),
        'nutritionPer100g': nutritionPer100g,
        'allergenStatements': allergenStatements,
        'dataSource': dataSource,
        'hasDiscrepancy': hasDiscrepancy,
        'discrepancyNote': discrepancyNote,
        'scannedAt': scannedAt.toIso8601String(),
      };
}
